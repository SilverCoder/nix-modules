# React Hooks & Patterns Reference

Complete reference for React hooks, composition patterns, and performance optimization.

## Built-in Hooks

### useState

```typescript
const [state, setState] = useState<T>(initialValue)
const [state, setState] = useState<T>(() => expensiveComputation())

// Functional updates
setState(prev => prev + 1)

// Common mistake: creating objects in render
❌ const [user, setUser] = useState({ name: '', age: 0 })  // New object every render
✅ const [user, setUser] = useState(() => ({ name: '', age: 0 }))

// Batch updates (automatic in React 18)
setCount(c => c + 1)
setFlag(f => !f)  // Batched together
```

### useEffect

```typescript
useEffect(() => {
  // Side effect
  const subscription = subscribe()

  // Cleanup
  return () => {
    subscription.unsubscribe()
  }
}, [dependencies])

// Empty deps = run once on mount
useEffect(() => {
  fetchData()
}, [])

// No deps = run after every render (usually wrong)
useEffect(() => {
  // Runs too often!
})
```

#### Common Patterns

```typescript
// Data fetching
useEffect(() => {
  let ignore = false

  async function fetchData() {
    const result = await fetch(url)
    if (!ignore) {
      setData(result)
    }
  }

  fetchData()
  return () => { ignore = true }  // Cleanup race condition
}, [url])

// Event listeners
useEffect(() => {
  function handleResize() {
    setWidth(window.innerWidth)
  }

  window.addEventListener('resize', handleResize)
  return () => window.removeEventListener('resize', handleResize)
}, [])

// Timer
useEffect(() => {
  const timer = setInterval(() => {
    setCount(c => c + 1)
  }, 1000)

  return () => clearInterval(timer)
}, [])
```

#### Anti-patterns

```typescript
// ❌ Missing dependencies
useEffect(() => {
  doSomething(props.value)  // props.value not in deps
}, [])

// ❌ Infinite loop
useEffect(() => {
  setData(computeData())  // Runs every render
})

// ❌ Dependency on object/array
const config = { url: '/api' }
useEffect(() => {
  fetch(config.url)
}, [config])  // config is new every render

// ✅ Fix: use specific values
useEffect(() => {
  fetch(config.url)
}, [config.url])
```

### useCallback

Memoize functions to prevent child re-renders:

```typescript
const memoizedCallback = useCallback(
  () => {
    doSomething(a, b)
  },
  [a, b]
)

// When to use
✅ Passing to memoized child components
✅ As dependency in useEffect
✅ With React.memo components

// When NOT to use
❌ Functions only used within component
❌ Functions passed to native elements (onClick, etc)
❌ Premature optimization
```

```typescript
// Example: prevent child re-render
const Parent = () => {
  const [count, setCount] = useState(0)

  // ❌ New function every render
  const handleClick = () => console.log('clicked')

  // ✅ Same function reference
  const handleClick = useCallback(() => {
    console.log('clicked')
  }, [])

  return <ExpensiveChild onClick={handleClick} />
}

const ExpensiveChild = React.memo(({ onClick }) => {
  // Only re-renders if onClick changes
})
```

### useMemo

Memoize expensive computations:

```typescript
const memoizedValue = useMemo(() => {
  return expensiveComputation(a, b)
}, [a, b])

// When to use
✅ Expensive calculations (filtering large arrays, etc)
✅ Referential equality for deps (objects/arrays)
✅ Avoiding prop changes for React.memo

// When NOT to use
❌ Cheap computations (< 1ms)
❌ Values that rarely change
❌ Premature optimization
```

```typescript
// Example: avoid unnecessary re-computation
const filteredList = useMemo(() => {
  return list.filter(item => item.active)  // Expensive for large lists
}, [list])

// Example: stable object reference
const config = useMemo(() => ({
  url: '/api',
  timeout: 5000
}), [])  // Same object every render
```

### useRef

Persist mutable value without causing re-render:

```typescript
const ref = useRef<T>(initialValue)

// Access via ref.current
ref.current = newValue  // Does NOT trigger re-render

// Common uses:
// 1. DOM references
const inputRef = useRef<HTMLInputElement>(null)
<input ref={inputRef} />
inputRef.current?.focus()

// 2. Previous value
const prevCount = useRef<number>()
useEffect(() => {
  prevCount.current = count
}, [count])

// 3. Mutable value in callbacks
const callbackRef = useRef<() => void>()
callbackRef.current = callback
useEffect(() => {
  callbackRef.current?.()
}, [])  // Stable deps

// 4. Instance variables
const timerRef = useRef<NodeJS.Timeout>()
timerRef.current = setInterval(() => {}, 1000)
```

### useContext

Access React context:

```typescript
const value = useContext(MyContext)

// Define context
const ThemeContext = createContext<'light' | 'dark'>('light')

// Provider
<ThemeContext.Provider value="dark">
  <App />
</ThemeContext.Provider>

// Consumer
const theme = useContext(ThemeContext)
```

#### Context Optimization

```typescript
// ❌ Re-renders all consumers
const [state, setState] = useState(initialState)
<MyContext.Provider value={{ state, setState }}>

// ✅ Memoize value
const value = useMemo(() => ({ state, setState }), [state])
<MyContext.Provider value={value}>

// ✅ Split contexts
<StateContext.Provider value={state}>
  <DispatchContext.Provider value={setState}>
    {children}
  </DispatchContext.Provider>
</StateContext.Provider>
```

### useReducer

Complex state logic:

```typescript
const [state, dispatch] = useReducer(reducer, initialState)

// Reducer function
function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { count: state.count + 1 }
    case 'decrement':
      return { count: state.count - 1 }
    default:
      return state
  }
}

// Usage
dispatch({ type: 'increment' })

// When to use
✅ Multiple related state values
✅ Complex state transitions
✅ State depends on previous state
❌ Simple independent values (use useState)
```

### useLayoutEffect

Synchronous layout effects (runs before paint):

```typescript
useLayoutEffect(() => {
  // Measure DOM, apply styles
  const height = ref.current.offsetHeight
  setHeight(height)
}, [])

// Use cases:
✅ DOM measurements
✅ Synchronous re-layout
✅ Preventing flicker
❌ Most other cases (use useEffect)
```

### useId

Generate unique IDs for accessibility:

```typescript
const id = useId()

<>
  <label htmlFor={id}>Name</label>
  <input id={id} type="text" />
</>

// For multiple IDs
const id = useId()
<>
  <label htmlFor={`${id}-name`}>Name</label>
  <input id={`${id}-name`} />
  <label htmlFor={`${id}-email`}>Email</label>
  <input id={`${id}-email`} />
</>
```

### useTransition

Mark state updates as non-urgent:

```typescript
const [isPending, startTransition] = useTransition()

startTransition(() => {
  setQuery(input)  // Low priority update
})

// Use while isPending true
{isPending && <Spinner />}

// Use cases:
✅ Expensive re-renders (large lists)
✅ Debounce-like behavior
✅ Keeping UI responsive
```

### useDeferredValue

Defer updating a value:

```typescript
const deferredValue = useDeferredValue(value)

// Example: keep input responsive
const [query, setQuery] = useState('')
const deferredQuery = useDeferredValue(query)

<>
  <input value={query} onChange={e => setQuery(e.target.value)} />
  <SearchResults query={deferredQuery} />  {/* Updates slower */}
</>
```

## Custom Hooks

### Patterns

```typescript
// 1. Reusable stateful logic
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key)
    return stored ? JSON.parse(stored) : initialValue
  })

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value))
  }, [key, value])

  return [value, setValue] as const
}

// 2. Encapsulate effects
function useDocumentTitle(title: string) {
  useEffect(() => {
    document.title = title
  }, [title])
}

// 3. Composition
function useUser(id: string) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    let ignore = false

    setLoading(true)
    fetchUser(id)
      .then(data => {
        if (!ignore) {
          setUser(data)
          setError(null)
        }
      })
      .catch(err => {
        if (!ignore) {
          setError(err)
        }
      })
      .finally(() => {
        if (!ignore) {
          setLoading(false)
        }
      })

    return () => { ignore = true }
  }, [id])

  return { user, loading, error }
}
```

### Common Custom Hooks

```typescript
// useDebounce
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(timer)
  }, [value, delay])

  return debouncedValue
}

// useMediaQuery
function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(false)

  useEffect(() => {
    const media = window.matchMedia(query)
    setMatches(media.matches)

    const listener = () => setMatches(media.matches)
    media.addEventListener('change', listener)
    return () => media.removeEventListener('change', listener)
  }, [query])

  return matches
}

// useIntersectionObserver
function useIntersectionObserver(
  ref: RefObject<Element>,
  options: IntersectionObserverInit = {}
): IntersectionObserverEntry | undefined {
  const [entry, setEntry] = useState<IntersectionObserverEntry>()

  useEffect(() => {
    const node = ref.current
    if (!node) return

    const observer = new IntersectionObserver(
      ([entry]) => setEntry(entry),
      options
    )

    observer.observe(node)
    return () => observer.disconnect()
  }, [ref, options.threshold, options.root, options.rootMargin])

  return entry
}

// usePrevious
function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>()

  useEffect(() => {
    ref.current = value
  }, [value])

  return ref.current
}
```

## Component Composition

### Compound Components

```typescript
const Tabs = ({ children }: { children: React.ReactNode }) => {
  const [active, setActive] = useState(0)

  return (
    <TabsContext.Provider value={{ active, setActive }}>
      {children}
    </TabsContext.Provider>
  )
}

const TabList = ({ children }: { children: React.ReactNode }) => (
  <div role="tablist">{children}</div>
)

const Tab = ({ index, children }: { index: number; children: React.ReactNode }) => {
  const { active, setActive } = useTabsContext()
  return (
    <button
      role="tab"
      aria-selected={active === index}
      onClick={() => setActive(index)}
    >
      {children}
    </button>
  )
}

// Usage
<Tabs>
  <TabList>
    <Tab index={0}>First</Tab>
    <Tab index={1}>Second</Tab>
  </TabList>
  <TabPanel index={0}>First content</TabPanel>
  <TabPanel index={1}>Second content</TabPanel>
</Tabs>
```

### Render Props

```typescript
type RenderProp<T> = (data: T) => React.ReactNode

const DataProvider = ({ render }: { render: RenderProp<Data> }) => {
  const data = useData()
  return <>{render(data)}</>
}

// Usage
<DataProvider render={data => (
  <div>{data.value}</div>
)} />
```

### Children as Function

```typescript
const List = <T,>({
  items,
  children,
}: {
  items: T[]
  children: (item: T, index: number) => React.ReactNode
}) => (
  <ul>
    {items.map((item, i) => (
      <li key={i}>{children(item, i)}</li>
    ))}
  </ul>
)

// Usage
<List items={users}>
  {(user, index) => (
    <UserCard user={user} index={index} />
  )}
</List>
```

### Slot Pattern

```typescript
const Card = ({
  header,
  footer,
  children,
}: {
  header?: React.ReactNode
  footer?: React.ReactNode
  children: React.ReactNode
}) => (
  <div className="card">
    {header && <div className="header">{header}</div>}
    <div className="body">{children}</div>
    {footer && <div className="footer">{footer}</div>}
  </div>
)

// Usage
<Card
  header={<h2>Title</h2>}
  footer={<Button>Save</Button>}
>
  Content
</Card>
```

## Performance Optimization

### React.memo

Prevent re-render if props haven't changed:

```typescript
const ExpensiveComponent = React.memo(({ data }: { data: Data }) => {
  // Only re-renders if `data` changes
  return <div>{data.value}</div>
})

// Custom comparison
const Component = React.memo(
  ({ user }: { user: User }) => <div>{user.name}</div>,
  (prevProps, nextProps) => prevProps.user.id === nextProps.user.id
)
```

### Lazy Loading

```typescript
import { lazy, Suspense } from 'react'

const HeavyComponent = lazy(() => import('./HeavyComponent'))

<Suspense fallback={<Spinner />}>
  <HeavyComponent />
</Suspense>
```

### Code Splitting

```typescript
// Route-based splitting
const Dashboard = lazy(() => import('./routes/Dashboard'))
const Settings = lazy(() => import('./routes/Settings'))

// Component-based splitting
const Modal = lazy(() => import('./components/Modal'))

// Conditional rendering with lazy
{showModal && (
  <Suspense fallback={<Spinner />}>
    <Modal />
  </Suspense>
)}
```

### Optimization Checklist

```typescript
// ❌ Creating functions/objects in render
const Component = () => {
  const handleClick = () => {}  // New every render
  const config = { url: '/api' }  // New every render
  return <Child onClick={handleClick} config={config} />
}

// ✅ Move outside or memoize
const handleClick = () => {}  // Outside component
const Component = () => {
  const memoizedClick = useCallback(() => {}, [])
  const config = useMemo(() => ({ url: '/api' }), [])
  return <Child onClick={memoizedClick} config={config} />
}

// ❌ Inline object/array props
<Component style={{ margin: 10 }} items={[1, 2, 3]} />

// ✅ Extract or memoize
const style = { margin: 10 }
const items = [1, 2, 3]
<Component style={style} items={items} />
```

## Best Practices

### Hook Rules

1. Only call at top level (not in loops/conditions)
2. Only call from React functions
3. Custom hooks start with "use"
4. List all dependencies in arrays

### Dependency Arrays

```typescript
// ✅ Complete dependencies
useEffect(() => {
  doSomething(a, b, c)
}, [a, b, c])

// ❌ Missing dependencies
useEffect(() => {
  doSomething(a, b, c)
}, [a])  // ESLint will warn

// ✅ Use ESLint rule
// eslint-plugin-react-hooks
```

### State Initialization

```typescript
// ❌ Expensive init every render
const [state, setState] = useState(expensiveComputation())

// ✅ Lazy initialization
const [state, setState] = useState(() => expensiveComputation())
```

### Cleanup

```typescript
useEffect(() => {
  // Setup
  const sub = subscribe()
  const timer = setInterval(() => {}, 1000)

  // Cleanup REQUIRED
  return () => {
    sub.unsubscribe()
    clearInterval(timer)
  }
}, [])
```
