# Server vs Client Components

Complete guide to Server and Client Components in Next.js App Router.

## Component Types

### Server Components (Default)

```typescript
// No directive needed - default in App Router
export default async function ServerComponent() {
  const data = await fetchData()  // Can be async
  return <div>{data}</div>
}
```

**Capabilities**:
- ✅ Async/await
- ✅ Direct database access
- ✅ Access secrets/env vars safely
- ✅ Large dependencies (stay on server)
- ✅ Reduce client bundle size
- ❌ No hooks (useState, useEffect, etc)
- ❌ No browser APIs
- ❌ No event handlers
- ❌ No Context providers/consumers

### Client Components

```typescript
'use client'

import { useState } from 'react'

export default function ClientComponent() {
  const [count, setCount] = useState(0)  // Hooks work
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>
}
```

**Capabilities**:
- ✅ Hooks (useState, useEffect, etc)
- ✅ Event handlers
- ✅ Browser APIs (window, localStorage, etc)
- ✅ Context providers/consumers
- ✅ Class components
- ❌ Async component functions
- ❌ Direct database access

## The `'use client'` Directive

### Boundary Rules

```typescript
// ❌ Wrong: directive in middle of file
import { useState } from 'react'
'use client'  // Must be at top

// ✅ Correct: first line
'use client'
import { useState } from 'react'
```

```typescript
// Marks THIS file and all imports as Client Components
'use client'

import { ServerComponent } from './server'  // Now client!
```

### When to Use

```typescript
// ✅ Leaf components needing interactivity
'use client'
export function Button({ onClick }: { onClick: () => void }) {
  return <button onClick={onClick}>Click</button>
}

// ❌ Don't mark entire tree
'use client'
export default function Page() {  // Makes everything client
  return (
    <>
      <Header />  {/* Now client */}
      <StaticContent />  {/* Now client */}
      <Button />  {/* Needed client */}
    </>
  )
}

// ✅ Keep tree mostly server
export default function Page() {  // Server
  return (
    <>
      <Header />  {/* Server */}
      <StaticContent />  {/* Server */}
      <Button />  {/* Client (has 'use client') */}
    </>
  )
}
```

## Composition Patterns

### Server Component → Client Component

```typescript
// app/page.tsx (Server Component)
import { ClientComponent } from './client'

export default async function Page() {
  const data = await fetchData()

  // ✅ Pass server data as props
  return <ClientComponent data={data} />
}

// app/client.tsx
'use client'
export function ClientComponent({ data }: { data: Data }) {
  const [selected, setSelected] = useState(data[0])
  return <div>{selected}</div>
}
```

### Client Component → Server Component

```typescript
// ❌ Can't import Server Component in Client
'use client'
import { ServerComponent } from './server'  // Becomes client!

export default function ClientComponent() {
  return <ServerComponent />  // Not server anymore
}

// ✅ Pass as children prop
'use client'
export default function ClientWrapper({
  children  // Server Component passed from parent
}: {
  children: React.ReactNode
}) {
  return <div className="wrapper">{children}</div>
}

// app/page.tsx (Server)
import { ClientWrapper } from './client-wrapper'
import { ServerComponent } from './server'

export default function Page() {
  return (
    <ClientWrapper>
      <ServerComponent />  {/* Stays server */}
    </ClientWrapper>
  )
}
```

### Passing Server Components as Props

```typescript
// Pattern: slots
// app/layout.tsx (Server)
import { Sidebar } from './sidebar'  // Server
import { Content } from './content'  // Client

export default function Layout() {
  return (
    <Content
      sidebar={<Sidebar />}  // Server Component as prop
    >
      {/* children */}
    </Content>
  )
}

// app/content.tsx
'use client'
export function Content({
  sidebar,
  children
}: {
  sidebar: React.ReactNode
  children: React.ReactNode
}) {
  return (
    <div>
      {sidebar}  {/* Rendered as Server Component */}
      {children}
    </div>
  )
}
```

## Serialization Rules

### What Can Be Passed

```typescript
// ✅ Serializable props
type SerializableProps = {
  string: string
  number: number
  boolean: boolean
  null: null
  array: SerializableProps[]
  object: { [key: string]: SerializableProps }
  date: Date  // Serialized as ISO string
}

// ❌ Non-serializable (Server → Client)
type InvalidProps = {
  function: () => void        // ❌ Functions
  classInstance: MyClass      // ❌ Class instances
  symbol: symbol              // ❌ Symbols
  undefined: undefined        // ❌ Undefined
  reactElement: JSX.Element   // ❌ React elements (use ReactNode)
}
```

### Passing Functions

```typescript
// ❌ Can't pass functions Server → Client
// app/page.tsx (Server)
export default function Page() {
  const handleClick = () => {}  // Server function

  return <ClientButton onClick={handleClick} />  // ❌ Error
}

// ✅ Use Server Actions
// app/page.tsx (Server)
import { ClientButton } from './client-button'

async function handleClick() {
  'use server'  // Server Action
  await updateDatabase()
}

export default function Page() {
  return <ClientButton action={handleClick} />  // ✅ Works
}

// app/client-button.tsx
'use client'
export function ClientButton({ action }: { action: () => Promise<void> }) {
  return <button onClick={() => action()}>Click</button>
}
```

## Context Patterns

### Problem: Context Providers Need Client

```typescript
// ❌ Can't use context in Server Component
import { ThemeContext } from './theme-context'

export default function ServerComponent() {
  const theme = useContext(ThemeContext)  // ❌ Error: no hooks
}
```

### Solution: Client Wrapper

```typescript
// app/providers.tsx
'use client'

import { createContext, useContext, useState } from 'react'

const ThemeContext = createContext<'light' | 'dark'>('light')

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')

  return (
    <ThemeContext.Provider value={theme}>
      {children}
    </ThemeContext.Provider>
  )
}

export function useTheme() {
  return useContext(ThemeContext)
}

// app/layout.tsx (Server)
import { ThemeProvider } from './providers'

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <ThemeProvider>
          {children}  {/* Can still be Server Components */}
        </ThemeProvider>
      </body>
    </html>
  )
}

// app/theme-button.tsx (Client)
'use client'
import { useTheme } from './providers'

export function ThemeButton() {
  const theme = useTheme()  // ✅ Works
  return <button>{theme}</button>
}
```

## Data Fetching

### Server Components

```typescript
// ✅ Direct async/await
export default async function Page() {
  const data = await fetch('https://api.example.com/data')
  const json = await data.json()

  return <div>{json.value}</div>
}

// ✅ Database queries
import { db } from '@/lib/db'

export default async function Page() {
  const users = await db.user.findMany()
  return <UserList users={users} />
}

// ✅ Parallel fetching
export default async function Page() {
  const [users, posts] = await Promise.all([
    fetchUsers(),
    fetchPosts(),
  ])

  return (
    <>
      <Users data={users} />
      <Posts data={posts} />
    </>
  )
}
```

### Client Components

```typescript
// ✅ useEffect + fetch
'use client'
import { useEffect, useState } from 'react'

export function ClientData() {
  const [data, setData] = useState(null)

  useEffect(() => {
    fetch('/api/data')
      .then(res => res.json())
      .then(setData)
  }, [])

  if (!data) return <Spinner />
  return <div>{data.value}</div>
}

// ✅ SWR / React Query
'use client'
import useSWR from 'swr'

export function ClientData() {
  const { data, error } = useSWR('/api/data', fetcher)

  if (error) return <Error />
  if (!data) return <Spinner />
  return <div>{data.value}</div>
}
```

### Hybrid Pattern

```typescript
// Server: initial data
export default async function Page() {
  const initialData = await fetchData()

  return <ClientComponent initialData={initialData} />
}

// Client: updates and interactivity
'use client'
import { useState } from 'react'

export function ClientComponent({ initialData }: { initialData: Data }) {
  const [data, setData] = useState(initialData)

  async function refresh() {
    const fresh = await fetch('/api/data').then(r => r.json())
    setData(fresh)
  }

  return (
    <>
      <div>{data.value}</div>
      <button onClick={refresh}>Refresh</button>
    </>
  )
}
```

## Server Actions

### Defining

```typescript
// In Server Component or separate file
async function createPost(formData: FormData) {
  'use server'

  const title = formData.get('title') as string
  await db.post.create({ data: { title } })
}

// Separate file: app/actions.ts
'use server'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  await db.post.create({ data: { title } })
}
```

### Using in Client Components

```typescript
// app/form.tsx
'use client'
import { createPost } from './actions'

export function Form() {
  return (
    <form action={createPost}>
      <input name="title" />
      <button type="submit">Submit</button>
    </form>
  )
}

// With pending state
'use client'
import { useFormStatus } from 'react-dom'
import { createPost } from './actions'

export function Form() {
  return (
    <form action={createPost}>
      <input name="title" />
      <SubmitButton />
    </form>
  )
}

function SubmitButton() {
  const { pending } = useFormStatus()
  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Submitting...' : 'Submit'}
    </button>
  )
}
```

### Progressive Enhancement

```typescript
// Works without JavaScript
export default function Page() {
  async function createTodo(formData: FormData) {
    'use server'
    const todo = formData.get('todo')
    await db.todo.create({ data: { text: todo } })
    revalidatePath('/todos')
  }

  return (
    <form action={createTodo}>
      <input name="todo" required />
      <button type="submit">Add</button>
    </form>
  )
}
```

### Server Action Patterns

```typescript
// Return data
async function updateUser(userId: string, data: UserData) {
  'use server'

  const user = await db.user.update({
    where: { id: userId },
    data,
  })

  return { success: true, user }
}

// Handle errors
async function createPost(formData: FormData) {
  'use server'

  try {
    const post = await db.post.create({ data: parse(formData) })
    revalidatePath('/posts')
    return { success: true, post }
  } catch (error) {
    return { success: false, error: error.message }
  }
}

// Client usage
'use client'
export function Form() {
  const [result, setResult] = useState(null)

  async function handleSubmit(formData: FormData) {
    const result = await createPost(formData)
    setResult(result)
  }

  return (
    <form action={handleSubmit}>
      {/* form fields */}
      {result?.error && <Error message={result.error} />}
    </form>
  )
}
```

## Common Mistakes

### Importing Server Code in Client

```typescript
// app/utils.ts
import { db } from './db'  // Database connection

export function getUser(id: string) {
  return db.user.findUnique({ where: { id } })
}

// app/client.tsx
'use client'
import { getUser } from './utils'  // ❌ Bundles database code!

export function User({ id }: { id: string }) {
  const [user, setUser] = useState(null)

  useEffect(() => {
    getUser(id).then(setUser)  // ❌ DB query in browser
  }, [id])

  return <div>{user?.name}</div>
}

// ✅ Fix: Server Action or API route
// app/actions.ts
'use server'
import { db } from './db'

export async function getUser(id: string) {
  return db.user.findUnique({ where: { id } })
}

// app/client.tsx
'use client'
import { getUser } from './actions'  // ✅ Safe

export function User({ id }: { id: string }) {
  const [user, setUser] = useState(null)

  useEffect(() => {
    getUser(id).then(setUser)  // ✅ Calls server
  }, [id])

  return <div>{user?.name}</div>
}
```

### Using Hooks in Server Components

```typescript
// ❌ Server Component with hooks
export default function Page() {
  const [state, setState] = useState(0)  // ❌ Error
  return <div>{state}</div>
}

// ✅ Extract to Client Component
export default function Page() {
  return <ClientCounter />
}

// client-counter.tsx
'use client'
export function ClientCounter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>
}
```

### Context Provider in Server

```typescript
// ❌ Context in Server Component
import { ThemeContext } from './theme'

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <ThemeContext.Provider value="dark">  {/* ❌ Error */}
      {children}
    </ThemeContext.Provider>
  )
}

// ✅ Client wrapper
// providers.tsx
'use client'
export function Providers({ children }: { children: ReactNode }) {
  return (
    <ThemeContext.Provider value="dark">
      {children}
    </ThemeContext.Provider>
  )
}

// layout.tsx (Server)
import { Providers } from './providers'

export default function Layout({ children }: { children: ReactNode }) {
  return <Providers>{children}</Providers>
}
```

## Decision Tree

```
Need interactivity (onClick, useState, etc)?
├─ YES → Client Component ('use client')
└─ NO → Can you keep as Server Component?
    ├─ YES → Server Component (default)
    └─ NO → Why?
        ├─ Needs hooks → Client Component
        ├─ Needs browser APIs → Client Component
        ├─ Third-party component needs client → Client Component
        └─ Context provider → Client wrapper
```

## Best Practices

1. **Default to Server** - Use Server Components unless you need client features
2. **Push 'use client' down** - Keep boundary as low in tree as possible
3. **Server data, client interactivity** - Fetch in Server, add interactivity in Client
4. **Pass Server as children** - Wrap Server Components with Client containers
5. **Server Actions for mutations** - Don't bundle server code in client
6. **Memoize context values** - Prevent unnecessary re-renders across boundary
