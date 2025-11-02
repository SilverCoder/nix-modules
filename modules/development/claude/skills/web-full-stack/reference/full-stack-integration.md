# Full-Stack Integration Patterns

Complete guide to integrating frontend and backend in Next.js App Router applications.

## Server Actions

### Basic Server Action

```typescript
// app/actions.ts
'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { db } from '@/lib/db'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  const content = formData.get('content') as string

  const post = await db.post.create({
    data: { title, content },
  })

  revalidatePath('/posts')
  redirect(`/posts/${post.id}`)
}

// app/new-post/page.tsx
import { createPost } from '@/app/actions'

export default function NewPost() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create</button>
    </form>
  )
}
```

### Server Action with Return Values

```typescript
// app/actions.ts
'use server'

export async function updateProfile(formData: FormData) {
  try {
    const name = formData.get('name') as string
    const email = formData.get('email') as string

    const user = await db.user.update({
      where: { id: getCurrentUserId() },
      data: { name, email },
    })

    revalidatePath('/profile')

    return {
      success: true,
      user,
    }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    }
  }
}

// app/profile/form.tsx
'use client'

import { updateProfile } from '@/app/actions'
import { useState } from 'react'

export function ProfileForm({ user }: { user: User }) {
  const [result, setResult] = useState<{ success: boolean; error?: string } | null>(null)

  async function handleSubmit(formData: FormData) {
    const result = await updateProfile(formData)
    setResult(result)
  }

  return (
    <form action={handleSubmit}>
      <input name="name" defaultValue={user.name} />
      <input name="email" defaultValue={user.email} />
      <button type="submit">Save</button>
      {result?.error && <Error message={result.error} />}
      {result?.success && <Success message="Profile updated!" />}
    </form>
  )
}
```

### Server Action with useFormStatus

```typescript
// app/actions.ts
'use server'

export async function submitForm(formData: FormData) {
  await new Promise(resolve => setTimeout(resolve, 2000))  // Simulate delay
  // Process formData
  return { success: true }
}

// app/form.tsx
'use client'

import { useFormStatus } from 'react-dom'
import { submitForm } from './actions'

function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Submitting...' : 'Submit'}
    </button>
  )
}

export function Form() {
  return (
    <form action={submitForm}>
      <input name="data" />
      <SubmitButton />
    </form>
  )
}
```

### Server Action with Validation

```typescript
// lib/validations.ts
import { z } from 'zod'

export const createPostSchema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(1),
  published: z.boolean().default(false),
})

// app/actions.ts
'use server'

import { createPostSchema } from '@/lib/validations'

export async function createPost(formData: FormData) {
  const rawData = {
    title: formData.get('title'),
    content: formData.get('content'),
    published: formData.get('published') === 'on',
  }

  const validated = createPostSchema.safeParse(rawData)

  if (!validated.success) {
    return {
      success: false,
      errors: validated.error.flatten().fieldErrors,
    }
  }

  const post = await db.post.create({
    data: validated.data,
  })

  revalidatePath('/posts')
  return { success: true, post }
}

// app/form.tsx
'use client'

export function PostForm() {
  const [errors, setErrors] = useState<Record<string, string[]>>({})

  async function handleSubmit(formData: FormData) {
    const result = await createPost(formData)

    if (!result.success) {
      setErrors(result.errors)
    } else {
      router.push(`/posts/${result.post.id}`)
    }
  }

  return (
    <form action={handleSubmit}>
      <input name="title" />
      {errors.title && <span className="text-red-500">{errors.title[0]}</span>}

      <textarea name="content" />
      {errors.content && <span className="text-red-500">{errors.content[0]}</span>}

      <button type="submit">Create</button>
    </form>
  )
}
```

## API Routes

### Basic Route Handler

```typescript
// app/api/posts/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { db } from '@/lib/db'

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams
  const limit = parseInt(searchParams.get('limit') || '10')

  const posts = await db.post.findMany({
    take: limit,
    orderBy: { createdAt: 'desc' },
  })

  return NextResponse.json(posts)
}

export async function POST(request: NextRequest) {
  const body = await request.json()

  const post = await db.post.create({
    data: body,
  })

  return NextResponse.json(post, { status: 201 })
}
```

### Dynamic Route Handler

```typescript
// app/api/posts/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const post = await db.post.findUnique({
    where: { id: params.id },
  })

  if (!post) {
    return NextResponse.json(
      { error: 'Post not found' },
      { status: 404 }
    )
  }

  return NextResponse.json(post)
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const body = await request.json()

  const post = await db.post.update({
    where: { id: params.id },
    data: body,
  })

  return NextResponse.json(post)
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  await db.post.delete({
    where: { id: params.id },
  })

  return new NextResponse(null, { status: 204 })
}
```

### Route Handler with Auth

```typescript
// lib/auth.ts
export async function getSession(request: NextRequest) {
  const token = request.cookies.get('session')?.value
  if (!token) return null

  const session = await verifyToken(token)
  return session
}

// app/api/protected/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { getSession } from '@/lib/auth'

export async function GET(request: NextRequest) {
  const session = await getSession(request)

  if (!session) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    )
  }

  const data = await fetchUserData(session.userId)

  return NextResponse.json(data)
}
```

### Route Handler with Streaming

```typescript
// app/api/stream/route.ts
import { NextRequest } from 'next/server'

export async function GET(request: NextRequest) {
  const encoder = new TextEncoder()

  const stream = new ReadableStream({
    async start(controller) {
      for (let i = 0; i < 10; i++) {
        const data = `data: ${JSON.stringify({ count: i })}\n\n`
        controller.enqueue(encoder.encode(data))
        await new Promise(resolve => setTimeout(resolve, 1000))
      }
      controller.close()
    },
  })

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  })
}
```

## Form Handling

### React Hook Form + Zod

```typescript
// lib/validations.ts
import { z } from 'zod'

export const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
})

export type LoginInput = z.infer<typeof loginSchema>

// app/login/form.tsx
'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { loginSchema, LoginInput } from '@/lib/validations'

export function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginInput>({
    resolver: zodResolver(loginSchema),
  })

  async function onSubmit(data: LoginInput) {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    })

    if (response.ok) {
      router.push('/dashboard')
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <input {...register('email')} type="email" />
        {errors.email && <span>{errors.email.message}</span>}
      </div>

      <div>
        <input {...register('password')} type="password" />
        {errors.password && <span>{errors.password.message}</span>}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Loading...' : 'Log in'}
      </button>
    </form>
  )
}
```

### shadcn Form Component

```typescript
// app/settings/form.tsx
'use client'

import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'
import { z } from 'zod'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { updateProfile } from '@/app/actions'

const formSchema = z.object({
  username: z.string().min(2).max(50),
  email: z.string().email(),
})

export function ProfileForm({ user }: { user: User }) {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      username: user.username,
      email: user.email,
    },
  })

  async function onSubmit(values: z.infer<typeof formSchema>) {
    await updateProfile(values)
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
        <FormField
          control={form.control}
          name="username"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Username</FormLabel>
              <FormControl>
                <Input placeholder="username" {...field} />
              </FormControl>
              <FormDescription>
                This is your public display name.
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Update profile</Button>
      </form>
    </Form>
  )
}
```

## Authentication

### Session-based Auth

```typescript
// lib/session.ts
import { cookies } from 'next/headers'
import { SignJWT, jwtVerify } from 'jose'

const secretKey = process.env.SESSION_SECRET!
const key = new TextEncoder().encode(secretKey)

export async function encrypt(payload: any) {
  return await new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('24h')
    .sign(key)
}

export async function decrypt(token: string): Promise<any> {
  const { payload } = await jwtVerify(token, key, {
    algorithms: ['HS256'],
  })
  return payload
}

export async function createSession(userId: string) {
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000)
  const session = await encrypt({ userId, expiresAt })

  cookies().set('session', session, {
    httpOnly: true,
    secure: true,
    expires: expiresAt,
    sameSite: 'lax',
    path: '/',
  })
}

export async function getSession() {
  const session = cookies().get('session')?.value
  if (!session) return null

  return await decrypt(session)
}

export async function deleteSession() {
  cookies().delete('session')
}

// app/login/actions.ts
'use server'

import { createSession } from '@/lib/session'
import { redirect } from 'next/navigation'

export async function login(formData: FormData) {
  const email = formData.get('email') as string
  const password = formData.get('password') as string

  const user = await verifyCredentials(email, password)

  if (!user) {
    return { error: 'Invalid credentials' }
  }

  await createSession(user.id)
  redirect('/dashboard')
}
```

### Middleware Protection

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server'
import { decrypt } from '@/lib/session'

const protectedRoutes = ['/dashboard', '/settings', '/profile']
const publicRoutes = ['/login', '/signup']

export async function middleware(request: NextRequest) {
  const path = request.nextUrl.pathname
  const isProtectedRoute = protectedRoutes.some(route => path.startsWith(route))
  const isPublicRoute = publicRoutes.includes(path)

  const cookie = request.cookies.get('session')?.value
  const session = cookie ? await decrypt(cookie) : null

  if (isProtectedRoute && !session) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  if (isPublicRoute && session) {
    return NextResponse.redirect(new URL('/dashboard', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
}
```

### Server Component Auth

```typescript
// app/dashboard/page.tsx
import { getSession } from '@/lib/session'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const session = await getSession()

  if (!session) {
    redirect('/login')
  }

  const user = await getUserById(session.userId)

  return <Dashboard user={user} />
}
```

## Error Handling

### Route Handler Errors

```typescript
// app/api/posts/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    // Validation
    if (!body.title) {
      return NextResponse.json(
        { error: 'Title is required' },
        { status: 400 }
      )
    }

    const post = await db.post.create({ data: body })

    return NextResponse.json(post, { status: 201 })
  } catch (error) {
    console.error('Error creating post:', error)

    if (error instanceof PrismaClientKnownRequestError) {
      if (error.code === 'P2002') {
        return NextResponse.json(
          { error: 'Post already exists' },
          { status: 409 }
        )
      }
    }

    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

### Server Action Errors

```typescript
// app/actions.ts
'use server'

import { revalidatePath } from 'next/cache'

export async function deletePost(postId: string) {
  try {
    await db.post.delete({
      where: { id: postId },
    })

    revalidatePath('/posts')

    return { success: true }
  } catch (error) {
    if (error instanceof NotFoundError) {
      return {
        success: false,
        error: 'Post not found',
      }
    }

    if (error instanceof UnauthorizedError) {
      return {
        success: false,
        error: 'You do not have permission to delete this post',
      }
    }

    console.error('Error deleting post:', error)

    return {
      success: false,
      error: 'Failed to delete post',
    }
  }
}
```

### Client-side Error Boundaries

```typescript
// app/error.tsx
'use client'

import { useEffect } from 'react'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error(error)
  }, [error])

  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

## Revalidation

### Path Revalidation

```typescript
// app/actions.ts
'use server'

import { revalidatePath } from 'next/cache'

export async function createPost(data: PostData) {
  const post = await db.post.create({ data })

  // Revalidate specific path
  revalidatePath('/posts')

  // Revalidate with layout
  revalidatePath('/posts', 'layout')

  // Revalidate with page only
  revalidatePath('/posts', 'page')

  return post
}
```

### Tag Revalidation

```typescript
// app/posts/page.tsx
export default async function PostsPage() {
  const posts = await fetch('https://api.example.com/posts', {
    next: { tags: ['posts'] }
  }).then(r => r.json())

  return <PostList posts={posts} />
}

// app/actions.ts
'use server'

import { revalidateTag } from 'next/cache'

export async function createPost(data: PostData) {
  const post = await db.post.create({ data })

  // Revalidate all fetches tagged with 'posts'
  revalidateTag('posts')

  return post
}
```

## Best Practices

1. **Server Actions for mutations** - Use for forms, not data fetching
2. **API Routes for external access** - When you need REST API
3. **Validate on server** - Never trust client data
4. **Return structured errors** - { success: boolean, error?: string }
5. **Use TypeScript** - Type forms, actions, responses
6. **Revalidate after mutations** - Keep UI in sync
7. **Handle errors gracefully** - Try/catch in actions and routes
8. **Protect routes** - Middleware for auth, not client-side
9. **Use form status hooks** - Show pending states
10. **Progressive enhancement** - Forms work without JS

## Common Patterns

### Optimistic Updates

```typescript
'use client'

import { updateTodo } from './actions'
import { useOptimistic } from 'react'

export function TodoList({ todos }: { todos: Todo[] }) {
  const [optimisticTodos, addOptimisticTodo] = useOptimistic(
    todos,
    (state, newTodo: Todo) => [...state, newTodo]
  )

  async function handleSubmit(formData: FormData) {
    const newTodo = {
      id: crypto.randomUUID(),
      text: formData.get('text') as string,
      completed: false,
    }

    addOptimisticTodo(newTodo)
    await createTodo(formData)
  }

  return (
    <>
      <form action={handleSubmit}>
        <input name="text" />
        <button type="submit">Add</button>
      </form>

      <ul>
        {optimisticTodos.map((todo) => (
          <li key={todo.id}>{todo.text}</li>
        ))}
      </ul>
    </>
  )
}
```

### Infinite Scroll

```typescript
'use client'

import { useEffect, useState } from 'react'
import { useInView } from 'react-intersection-observer'

export function InfiniteList({ initialPosts }: { initialPosts: Post[] }) {
  const [posts, setPosts] = useState(initialPosts)
  const [page, setPage] = useState(1)
  const { ref, inView } = useInView()

  useEffect(() => {
    if (inView) {
      fetch(`/api/posts?page=${page + 1}`)
        .then(r => r.json())
        .then(newPosts => {
          setPosts(prev => [...prev, ...newPosts])
          setPage(prev => prev + 1)
        })
    }
  }, [inView, page])

  return (
    <>
      {posts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
      <div ref={ref}>Loading...</div>
    </>
  )
}
```
