# Next.js App Router Reference

Complete reference for Next.js 13+ App Router patterns, file conventions, and APIs.

## File Conventions

### Special Files

| File | Purpose | Exports |
|------|---------|---------|
| `page.tsx` | Unique UI for route | `default export` component |
| `layout.tsx` | Shared UI for segment and children | `default export` component |
| `template.tsx` | Re-rendered shared UI | `default export` component |
| `loading.tsx` | Loading UI (Suspense boundary) | `default export` component |
| `error.tsx` | Error UI (Error boundary) | `'use client'` + default export |
| `not-found.tsx` | Not found UI | `default export` component |
| `route.tsx` | API endpoint | `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`, `OPTIONS` |
| `default.tsx` | Fallback for parallel routes | `default export` component |

### File Props

```typescript
// page.tsx
export default function Page({
  params,        // { slug: 'hello' } for /posts/[slug]
  searchParams   // { query: 'test' } for ?query=test
}: {
  params: { slug: string }
  searchParams: { [key: string]: string | string[] | undefined }
}) {}

// layout.tsx
export default function Layout({
  children,
  params         // Only has params, not searchParams
}: {
  children: React.ReactNode
  params: { slug: string }
}) {}

// error.tsx
'use client'
export default function Error({
  error,
  reset          // Function to retry
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {}
```

## Route Segment Config

Configure route behavior via exports:

```typescript
// Static or dynamic rendering
export const dynamic = 'auto' | 'force-dynamic' | 'error' | 'force-static'

// Revalidation interval (seconds)
export const revalidate = false | 0 | number

// Runtime
export const runtime = 'nodejs' | 'edge'

// Route segment cache behavior
export const fetchCache = 'auto' | 'default-cache' | 'only-cache' | 'force-cache' | 'force-no-store' | 'default-no-store' | 'only-no-store'

// Dynamic params
export const dynamicParams = true | false

// Prefer dynamic rendering
export const preferredRegion = 'auto' | 'global' | 'home' | string | string[]

// Maximum duration for serverless functions
export const maxDuration = number
```

### Common Patterns

```typescript
// Force dynamic (no caching)
export const dynamic = 'force-dynamic'
export const revalidate = 0

// Static generation with ISR
export const revalidate = 3600 // revalidate every hour

// Edge runtime
export const runtime = 'edge'
```

## Metadata API

### Static Metadata

```typescript
import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Page Title',
  description: 'Page description',
  openGraph: {
    title: 'OG Title',
    description: 'OG Description',
    images: ['/og-image.jpg'],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Twitter Title',
    description: 'Twitter Description',
    images: ['/twitter-image.jpg'],
  },
  icons: {
    icon: '/icon.png',
    apple: '/apple-icon.png',
  },
  robots: {
    index: true,
    follow: true,
  },
}
```

### Dynamic Metadata

```typescript
import { Metadata } from 'next'

export async function generateMetadata({
  params,
  searchParams,
}: {
  params: { slug: string }
  searchParams: { [key: string]: string | string[] | undefined }
}): Promise<Metadata> {
  const post = await getPost(params.slug)

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [post.image],
    },
  }
}
```

### Title Templates

```typescript
// layout.tsx
export const metadata: Metadata = {
  title: {
    template: '%s | My Site',
    default: 'My Site',
  },
}

// page.tsx
export const metadata: Metadata = {
  title: 'About', // Becomes "About | My Site"
}
```

## Dynamic Functions

Functions that opt route into dynamic rendering:

```typescript
import { cookies, headers } from 'next/headers'
import { redirect, notFound } from 'next/navigation'

// Read cookies
const cookieStore = cookies()
const theme = cookieStore.get('theme')

// Read headers
const headersList = headers()
const userAgent = headersList.get('user-agent')

// Programmatic navigation
redirect('/login') // 307 temporary
permanentRedirect('/new-url') // 308 permanent

// Trigger not-found.tsx
notFound()
```

## Static Generation

### generateStaticParams

Pre-render dynamic routes at build time:

```typescript
// app/posts/[slug]/page.tsx
export async function generateStaticParams() {
  const posts = await getPosts()

  return posts.map((post) => ({
    slug: post.slug,
  }))
}

export default function Page({ params }: { params: { slug: string } }) {
  return <div>{params.slug}</div>
}
```

### Multiple Dynamic Segments

```typescript
// app/posts/[category]/[slug]/page.tsx
export async function generateStaticParams() {
  const posts = await getPosts()

  return posts.map((post) => ({
    category: post.category,
    slug: post.slug,
  }))
}
```

### Catch-all with staticParams

```typescript
// app/docs/[[...slug]]/page.tsx
export async function generateStaticParams() {
  return [
    { slug: ['getting-started'] },
    { slug: ['api', 'reference'] },
    { slug: ['guides', 'deployment', 'vercel'] },
  ]
}
```

## Route Groups

Organize routes without affecting URL structure:

```
app/
├── (marketing)/
│   ├── layout.tsx       # Marketing layout
│   ├── page.tsx         # / (homepage)
│   └── about/
│       └── page.tsx     # /about
├── (dashboard)/
│   ├── layout.tsx       # Dashboard layout
│   ├── settings/
│   │   └── page.tsx     # /settings
│   └── profile/
│       └── page.tsx     # /profile
└── layout.tsx           # Root layout
```

## Parallel Routes

Render multiple pages in same layout:

```
app/
├── @modal/
│   ├── default.tsx      # Fallback (prevents 404)
│   └── login/
│       └── page.tsx
├── @sidebar/
│   ├── default.tsx
│   └── page.tsx
├── layout.tsx
└── page.tsx
```

```typescript
// app/layout.tsx
export default function Layout({
  children,
  modal,
  sidebar,
}: {
  children: React.ReactNode
  modal: React.ReactNode
  sidebar: React.ReactNode
}) {
  return (
    <>
      {sidebar}
      {children}
      {modal}
    </>
  )
}
```

## Intercepting Routes

Intercept navigation to show modal while preserving URL:

```
app/
├── photo/
│   └── [id]/
│       └── page.tsx     # Direct access
├── (.)/photo/
│   └── [id]/
│       └── page.tsx     # Intercept same level
├── (..)/photo/
│   └── [id]/
│       └── page.tsx     # Intercept one level up
└── (...)/photo/
    └── [id]/
        └── page.tsx     # Intercept from root
```

Patterns:
- `(.)` - match same level
- `(..)` - match one level up
- `(..)(..)` - match two levels up
- `(...)` - match from app root

## Streaming & Suspense

### Loading UI

```typescript
// app/dashboard/loading.tsx
export default function Loading() {
  return <Skeleton />
}

// Equivalent to:
// <Suspense fallback={<Skeleton />}>
//   <Page />
// </Suspense>
```

### Manual Suspense

```typescript
import { Suspense } from 'react'

export default function Page() {
  return (
    <>
      <Header />
      <Suspense fallback={<Spinner />}>
        <DataComponent />
      </Suspense>
      <Footer />
    </>
  )
}
```

## Middleware

```typescript
// middleware.ts (in app root or src/)
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // Check authentication
  const token = request.cookies.get('token')
  if (!token) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Add custom header
  const response = NextResponse.next()
  response.headers.set('x-custom-header', 'value')
  return response
}

// Match specific paths
export const config = {
  matcher: [
    '/dashboard/:path*',
    '/api/:path*',
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ],
}
```

## Route Handlers (API Routes)

```typescript
// app/api/posts/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams
  const query = searchParams.get('query')

  const posts = await getPosts(query)
  return NextResponse.json(posts)
}

export async function POST(request: NextRequest) {
  const body = await request.json()
  const post = await createPost(body)
  return NextResponse.json(post, { status: 201 })
}

// Dynamic routes
// app/api/posts/[id]/route.ts
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const post = await getPost(params.id)
  return NextResponse.json(post)
}
```

### Route Handler Options

```typescript
// Opt out of caching
export const dynamic = 'force-dynamic'

// Edge runtime
export const runtime = 'edge'

// Revalidate
export const revalidate = 60
```

## Common Patterns

### Conditional Redirects

```typescript
// app/dashboard/page.tsx
import { redirect } from 'next/navigation'
import { auth } from '@/lib/auth'

export default async function DashboardPage() {
  const session = await auth()

  if (!session) {
    redirect('/login')
  }

  return <Dashboard user={session.user} />
}
```

### Parallel Data Fetching

```typescript
// app/page.tsx
export default async function Page() {
  // Fetch in parallel
  const [user, posts] = await Promise.all([
    getUser(),
    getPosts(),
  ])

  return (
    <>
      <Profile user={user} />
      <Feed posts={posts} />
    </>
  )
}
```

### Nested Layouts

```
app/
├── layout.tsx                    # Root: <html>, <body>
├── (marketing)/
│   ├── layout.tsx                # Marketing: header, footer
│   └── page.tsx
└── (dashboard)/
    ├── layout.tsx                # Dashboard: sidebar
    ├── settings/
    │   ├── layout.tsx            # Settings: tabs
    │   ├── profile/
    │   │   └── page.tsx
    └── └── account/
            └── page.tsx
```

Layouts nest: Root → Marketing → Settings → Page
