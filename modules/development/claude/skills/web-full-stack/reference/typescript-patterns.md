# TypeScript React Patterns

Complete guide to TypeScript patterns for React components, props, hooks, and utilities.

## Component Typing

### Function Components

```typescript
// Basic component
function Component() {
  return <div>Hello</div>
}

// With props
interface Props {
  name: string
  age?: number
}

function Component({ name, age }: Props) {
  return <div>{name} is {age} years old</div>
}

// With children
interface Props {
  children: React.ReactNode
}

function Component({ children }: Props) {
  return <div>{children}</div>
}

// ❌ Don't use React.FC (deprecated pattern)
const Component: React.FC<Props> = ({ children }) => {
  return <div>{children}</div>
}

// ✅ Use function with typed props
function Component({ children }: { children: React.ReactNode }) {
  return <div>{children}</div>
}
```

### Props Patterns

```typescript
// Extending HTML attributes
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary'
}

function Button({ variant = 'primary', children, ...props }: ButtonProps) {
  return <button {...props}>{children}</button>
}

// Usage preserves all button attributes
<Button onClick={() => {}} disabled className="mt-4" />

// Omitting props
interface InputProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, 'type'> {
  type: 'email' | 'password'  // Narrow down type
}

// Pick specific props
interface LinkProps extends Pick<React.AnchorHTMLAttributes<HTMLAnchorElement>, 'href' | 'target'> {
  children: React.ReactNode
}
```

### Children Types

```typescript
// ReactNode (most common - accepts anything renderable)
function Component({ children }: { children: React.ReactNode }) {}

// ReactElement (only single React element)
function Component({ children }: { children: React.ReactElement }) {}

// Array of elements
function Component({ children }: { children: React.ReactElement[] }) {}

// Render prop
function Component({ render }: { render: (data: Data) => React.ReactNode }) {
  return <>{render(data)}</>
}

// Children as function
function Component({
  children,
}: {
  children: (data: Data) => React.ReactNode
}) {
  return <>{children(data)}</>
}

// Specific component type
function List({
  children,
}: {
  children: React.ReactElement<ListItemProps> | React.ReactElement<ListItemProps>[]
}) {
  return <ul>{children}</ul>
}
```

### Event Handlers

```typescript
// Mouse events
function handleClick(e: React.MouseEvent<HTMLButtonElement>) {
  e.currentTarget  // HTMLButtonElement
  e.target         // EventTarget
}

<button onClick={handleClick}>Click</button>

// Form events
function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
  e.preventDefault()
}

function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
  const value = e.target.value
}

<form onSubmit={handleSubmit}>
  <input onChange={handleChange} />
</form>

// Keyboard events
function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
  if (e.key === 'Enter') {
    // ...
  }
}

// Focus events
function handleFocus(e: React.FocusEvent<HTMLInputElement>) {}

// Common pattern: inline handler type inference
<button onClick={(e) => {
  // e is automatically React.MouseEvent<HTMLButtonElement>
}}>
```

### Ref Types

```typescript
// DOM element ref
const inputRef = useRef<HTMLInputElement>(null)
<input ref={inputRef} />

// Later access (null check required)
inputRef.current?.focus()

// Component instance ref (class components)
const componentRef = useRef<MyClassComponent>(null)
<MyClassComponent ref={componentRef} />

// Mutable value ref
const timerRef = useRef<NodeJS.Timeout>()
timerRef.current = setTimeout(() => {}, 1000)

// Forwarding refs
interface Props {
  // props
}

const Input = forwardRef<HTMLInputElement, Props>(
  (props, ref) => {
    return <input ref={ref} {...props} />
  }
)

// Usage
const inputRef = useRef<HTMLInputElement>(null)
<Input ref={inputRef} />
```

## Hook Typing

### useState

```typescript
// Type inference
const [count, setCount] = useState(0)  // number
const [name, setName] = useState('')   // string

// Explicit type
const [user, setUser] = useState<User | null>(null)

// With union types
const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle')

// Complex state
interface State {
  data: Data | null
  loading: boolean
  error: Error | null
}

const [state, setState] = useState<State>({
  data: null,
  loading: false,
  error: null,
})

// Lazy initialization typed
const [value, setValue] = useState<number>(() => {
  return expensiveComputation()  // Must return number
})
```

### useReducer

```typescript
// State type
interface State {
  count: number
  user: User | null
}

// Action types
type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'setUser'; payload: User }
  | { type: 'reset' }

// Reducer
function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + 1 }
    case 'decrement':
      return { ...state, count: state.count - 1 }
    case 'setUser':
      return { ...state, user: action.payload }
    case 'reset':
      return initialState
    default:
      return state
  }
}

// Usage
const [state, dispatch] = useReducer(reducer, initialState)

// Type-safe dispatch
dispatch({ type: 'increment' })
dispatch({ type: 'setUser', payload: user })
dispatch({ type: 'invalid' })  // ❌ Error
```

### useRef

```typescript
// DOM ref
const inputRef = useRef<HTMLInputElement>(null)

// Mutable value (initialized)
const countRef = useRef<number>(0)
countRef.current = 1  // ✅ Works

// Mutable value (possibly undefined)
const timerRef = useRef<NodeJS.Timeout>()
timerRef.current = setTimeout(() => {}, 1000)  // ✅ Works
clearTimeout(timerRef.current)  // Type: NodeJS.Timeout | undefined

// Non-null ref (when you know it exists)
const ref = useRef<HTMLDivElement>(null!)  // ! asserts non-null
ref.current.focus()  // ✅ No null check needed (dangerous!)
```

### useContext

```typescript
// Define context type
interface ThemeContextType {
  theme: 'light' | 'dark'
  setTheme: (theme: 'light' | 'dark') => void
}

// Create context with type
const ThemeContext = createContext<ThemeContextType | undefined>(undefined)

// Provider
function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')

  const value: ThemeContextType = {
    theme,
    setTheme,
  }

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}

// Custom hook with type guard
function useTheme(): ThemeContextType {
  const context = useContext(ThemeContext)
  if (context === undefined) {
    throw new Error('useTheme must be used within ThemeProvider')
  }
  return context
}

// Usage
const { theme, setTheme } = useTheme()  // Fully typed
```

### Custom Hook Typing

```typescript
// Return tuple (as const)
function useToggle(initialValue: boolean = false) {
  const [value, setValue] = useState(initialValue)
  const toggle = useCallback(() => setValue(v => !v), [])

  return [value, toggle] as const  // Tuple, not array
}

const [isOpen, toggle] = useToggle(false)  // Correct types

// Return object
interface UseDataReturn<T> {
  data: T | null
  loading: boolean
  error: Error | null
  refetch: () => void
}

function useData<T>(url: string): UseDataReturn<T> {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const refetch = useCallback(() => {
    // fetch logic
  }, [url])

  return { data, loading, error, refetch }
}

// Usage (type inference)
const { data, loading, error } = useData<User>('/api/user')
// data is User | null
```

## Generic Components

### Basic Generic

```typescript
interface ListProps<T> {
  items: T[]
  renderItem: (item: T) => React.ReactNode
}

function List<T>({ items, renderItem }: ListProps<T>) {
  return (
    <ul>
      {items.map((item, index) => (
        <li key={index}>{renderItem(item)}</li>
      ))}
    </ul>
  )
}

// Usage (type inference)
<List
  items={users}
  renderItem={(user) => <UserCard user={user} />}  // user is User
/>

<List
  items={posts}
  renderItem={(post) => <PostCard post={post} />}  // post is Post
/>
```

### Generic with Constraints

```typescript
interface Item {
  id: string
  name: string
}

interface SelectProps<T extends Item> {
  items: T[]
  value: T
  onChange: (item: T) => void
}

function Select<T extends Item>({
  items,
  value,
  onChange,
}: SelectProps<T>) {
  return (
    <select
      value={value.id}
      onChange={(e) => {
        const item = items.find((i) => i.id === e.target.value)
        if (item) onChange(item)
      }}
    >
      {items.map((item) => (
        <option key={item.id} value={item.id}>
          {item.name}
        </option>
      ))}
    </select>
  )
}
```

## Utility Types

### Component Props Extraction

```typescript
// Extract props from component
import { Button } from './Button'

type ButtonProps = React.ComponentProps<typeof Button>

// Extract HTML element props
type DivProps = React.ComponentProps<'div'>
type InputProps = React.ComponentProps<'input'>

// Use in new component
interface WrapperProps extends ButtonProps {
  label: string
}
```

### Prop Manipulation

```typescript
// Make all props optional
type PartialProps = Partial<Props>

// Make all props required
type RequiredProps = Required<Props>

// Pick specific props
type PickedProps = Pick<Props, 'name' | 'age'>

// Omit specific props
type OmittedProps = Omit<Props, 'internal' | 'private'>

// Make specific prop required
type PropsWithRequired<T, K extends keyof T> = T & Required<Pick<T, K>>

interface Props {
  name?: string
  age?: number
}

type PropsWithName = PropsWithRequired<Props, 'name'>
// { name: string, age?: number }
```

### Event Types

```typescript
// Extract event handler type
type ClickHandler = React.MouseEventHandler<HTMLButtonElement>

// Create handler type from event
type OnChange = (event: React.ChangeEvent<HTMLInputElement>) => void

// Props with handlers
interface Props {
  onClick?: React.MouseEventHandler<HTMLButtonElement>
  onChange?: React.ChangeEventHandler<HTMLInputElement>
  onSubmit?: React.FormEventHandler<HTMLFormElement>
}
```

## Advanced Patterns

### Discriminated Unions

```typescript
// State with status
type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error }

function Component() {
  const [state, setState] = useState<AsyncState<User>>({ status: 'idle' })

  // Type narrowing
  if (state.status === 'loading') {
    return <Spinner />
  }

  if (state.status === 'error') {
    return <Error message={state.error.message} />  // ✅ error exists
  }

  if (state.status === 'success') {
    return <UserCard user={state.data} />  // ✅ data exists
  }

  return <div>Idle</div>
}
```

### Polymorphic Components

```typescript
// Component that can be rendered as different elements
type AsProp<C extends React.ElementType> = {
  as?: C
}

type PropsToOmit<C extends React.ElementType, P> = keyof (AsProp<C> & P)

type PolymorphicComponentProp<
  C extends React.ElementType,
  Props = {}
> = React.PropsWithChildren<Props & AsProp<C>> &
  Omit<React.ComponentPropsWithoutRef<C>, PropsToOmit<C, Props>>

interface TextOwnProps {
  color?: 'primary' | 'secondary'
}

type TextProps<C extends React.ElementType> = PolymorphicComponentProp<
  C,
  TextOwnProps
>

function Text<C extends React.ElementType = 'span'>({
  as,
  color = 'primary',
  children,
  ...props
}: TextProps<C>) {
  const Component = as || 'span'
  return <Component {...props}>{children}</Component>
}

// Usage
<Text>Default span</Text>
<Text as="p">Paragraph</Text>
<Text as="a" href="/link">Link</Text>  // href is valid
<Text as="button" onClick={() => {}}>Button</Text>  // onClick is valid
```

### HOC Typing

```typescript
// Higher-Order Component
function withLoading<P extends object>(
  Component: React.ComponentType<P>
) {
  return function WithLoading(props: P & { loading: boolean }) {
    const { loading, ...rest } = props

    if (loading) {
      return <Spinner />
    }

    return <Component {...(rest as P)} />
  }
}

// Usage
interface Props {
  data: string
}

function MyComponent({ data }: Props) {
  return <div>{data}</div>
}

const MyComponentWithLoading = withLoading(MyComponent)

<MyComponentWithLoading data="test" loading={false} />
```

### Render Props

```typescript
interface RenderProps<T> {
  data: T
  loading: boolean
  error: Error | null
}

interface DataProviderProps<T> {
  url: string
  children: (props: RenderProps<T>) => React.ReactNode
}

function DataProvider<T>({ url, children }: DataProviderProps<T>) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  // fetch logic...

  return <>{children({ data: data!, loading, error })}</>
}

// Usage
<DataProvider<User> url="/api/user">
  {({ data, loading, error }) => {
    if (loading) return <Spinner />
    if (error) return <Error error={error} />
    return <UserCard user={data} />
  }}
</DataProvider>
```

## Best Practices

1. **Infer when possible** - Let TypeScript infer types from values
2. **Explicit for public APIs** - Type function parameters, component props
3. **Use strict mode** - Enable `strict: true` in tsconfig.json
4. **Discriminated unions for state** - Better than nullable fields
5. **as const for tuples** - Return [value, setter] as const
6. **extends for HTML props** - Preserve native element attributes
7. **Generics for reusable components** - List, Select, etc.
8. **Type guards for narrowing** - Check status before accessing fields

## Common Mistakes

```typescript
// ❌ Using any
function Component({ data }: { data: any }) {}

// ✅ Use proper types or unknown
function Component({ data }: { data: User }) {}
function Component({ data }: { data: unknown }) {
  // Type guard before use
}

// ❌ Type assertions everywhere
const value = data as string
const element = ref.current as HTMLInputElement

// ✅ Type guards and proper typing
if (typeof data === 'string') {
  // data is string
}

if (ref.current) {
  ref.current.focus()  // Null check
}

// ❌ Optional refs without null checks
const ref = useRef<HTMLDivElement>(null)
ref.current.focus()  // ❌ Might be null

// ✅ Null check
ref.current?.focus()
```
