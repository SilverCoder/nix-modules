# Tailwind CSS + shadcn/ui Reference

Complete guide to Tailwind utility patterns and shadcn component composition.

## Tailwind Utility Patterns

### Layout

```tsx
// Flex patterns
<div className="flex items-center justify-between">  {/* Horizontal space-between */}
<div className="flex items-center justify-center">   {/* Center everything */}
<div className="flex items-start gap-4">            {/* Vertical align top, gap */}
<div className="flex flex-col gap-2">              {/* Vertical stack */}
<div className="flex flex-wrap gap-4">             {/* Wrap items */}

// Grid patterns
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
<div className="grid grid-cols-[200px_1fr] gap-4">  {/* Sidebar + main */}
<div className="grid place-items-center">           {/* Center content */}

// Container
<div className="container mx-auto px-4">            {/* Centered container */}
<div className="max-w-7xl mx-auto">                 {/* Max width container */}

// Full viewport
<div className="min-h-screen flex flex-col">        {/* Full height layout */}
<div className="h-screen overflow-y-auto">          {/* Scrollable viewport */}
```

### Spacing

```tsx
// Padding
<div className="p-4">          {/* All sides: 1rem */}
<div className="px-4 py-2">    {/* Horizontal + vertical */}
<div className="pt-8 pb-4">    {/* Top + bottom */}

// Margin
<div className="m-4">          {/* All sides */}
<div className="mx-auto">      {/* Center horizontally */}
<div className="mt-4 mb-8">    {/* Top + bottom */}
<div className="-mt-4">        {/* Negative margin */}

// Gap (flex/grid)
<div className="flex gap-4">           {/* 1rem gap */}
<div className="grid gap-x-4 gap-y-8"> {/* Different x/y gaps */}

// Space between
<div className="flex flex-col space-y-4">  {/* Vertical spacing */}
<div className="flex space-x-4">           {/* Horizontal spacing */}
```

### Sizing

```tsx
// Width
<div className="w-full">       {/* 100% */}
<div className="w-1/2">        {/* 50% */}
<div className="w-64">         {/* 16rem (256px) */}
<div className="max-w-md">     {/* Max 28rem */}
<div className="min-w-0">      {/* Prevent overflow */}

// Height
<div className="h-screen">     {/* 100vh */}
<div className="h-full">       {/* 100% */}
<div className="h-64">         {/* 16rem */}
<div className="min-h-screen"> {/* Min viewport height */}

// Arbitrary values
<div className="w-[250px]">    {/* Exact 250px */}
<div className="h-[calc(100vh-64px)]">  {/* Custom calc */}
```

### Typography

```tsx
// Size
<p className="text-sm">        {/* 0.875rem */}
<p className="text-base">      {/* 1rem */}
<p className="text-lg">        {/* 1.125rem */}
<p className="text-xl">        {/* 1.25rem */}
<p className="text-2xl">       {/* 1.5rem */}

// Weight
<p className="font-normal">    {/* 400 */}
<p className="font-medium">    {/* 500 */}
<p className="font-semibold">  {/* 600 */}
<p className="font-bold">      {/* 700 */}

// Line height
<p className="leading-none">   {/* 1 */}
<p className="leading-tight">  {/* 1.25 */}
<p className="leading-normal"> {/* 1.5 */}
<p className="leading-relaxed">{/* 1.625 */}

// Other
<p className="text-center">    {/* Center text */}
<p className="truncate">       {/* Ellipsis overflow */}
<p className="line-clamp-3">   {/* Truncate after 3 lines */}
```

### Colors

```tsx
// Background
<div className="bg-white">
<div className="bg-slate-100">
<div className="bg-blue-500">
<div className="bg-gradient-to-r from-blue-500 to-purple-500">

// Text
<p className="text-slate-900">
<p className="text-blue-600">
<p className="text-red-500">

// Border
<div className="border border-slate-200">
<div className="border-2 border-blue-500">
<div className="border-t border-b">  {/* Top + bottom only */}
```

### Responsive Design

```tsx
// Mobile-first
<div className="text-sm md:text-base lg:text-lg">
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
<div className="hidden md:block">      {/* Hidden on mobile */}
<div className="md:hidden">            {/* Mobile only */}

// Breakpoints: sm (640px), md (768px), lg (1024px), xl (1280px), 2xl (1536px)

// Container queries
<div className="@container">
  <div className="@md:text-lg">       {/* Based on container, not viewport */}
</div>
```

### Dark Mode

```tsx
// Setup: tailwind.config.ts
darkMode: 'class'  // or 'media'

// Usage
<div className="bg-white dark:bg-slate-900">
<p className="text-slate-900 dark:text-slate-100">
<div className="border-slate-200 dark:border-slate-700">

// Group dark mode
<div className="group dark:bg-slate-800">
  <p className="group-hover:text-blue-500 dark:group-hover:text-blue-400">
</div>
```

### States

```tsx
// Hover
<button className="hover:bg-blue-600">
<button className="hover:scale-105">

// Focus
<input className="focus:ring-2 focus:ring-blue-500">
<input className="focus-visible:outline-none focus-visible:ring-2">

// Active
<button className="active:scale-95">

// Disabled
<button className="disabled:opacity-50 disabled:cursor-not-allowed">

// Group hover
<div className="group">
  <p className="group-hover:text-blue-500">
</div>

// Peer (sibling state)
<input className="peer" type="checkbox" />
<label className="peer-checked:text-blue-500">
```

### Advanced Patterns

```tsx
// Arbitrary variants
<div className="[&>p]:text-blue-500">         {/* All p children */}
<div className="[&:nth-child(3)]:font-bold">   {/* Specific child */}

// Arbitrary properties
<div className="[mask-image:linear-gradient(...)]">

// Data attributes
<div data-state="active" className="data-[state=active]:bg-blue-500">

// Custom modifiers
<div className="supports-[display:grid]:grid">
```

## shadcn/ui Patterns

### Installation

```bash
npx shadcn-ui@latest init
npx shadcn-ui@latest add button
npx shadcn-ui@latest add form
```

### Component Structure

```tsx
// components/ui/button.tsx
import { cn } from "@/lib/utils"
import { cva, type VariantProps } from "class-variance-authority"

const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input hover:bg-accent",
        ghost: "hover:bg-accent hover:text-accent-foreground",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 px-3",
        lg: "h-11 px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

interface ButtonProps extends VariantProps<typeof buttonVariants> {
  // ...
}

const Button = ({ className, variant, size, ...props }: ButtonProps) => {
  return (
    <button
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  )
}
```

### Using cn() Utility

```tsx
import { cn } from "@/lib/utils"

// Merge classes safely
<div className={cn(
  "base-class",
  condition && "conditional-class",
  "always-applied"
)} />

// Override component styles
<Button className="bg-red-500" />  {/* Overrides default bg */}

// Conditional variants
<Button
  variant={isDestructive ? "destructive" : "default"}
  className={cn(
    isDestructive && "shadow-lg",
    isDisabled && "opacity-50"
  )}
/>
```

### Customizing Components

```tsx
// Extend existing component
import { Button } from "@/components/ui/button"

export function IconButton({
  icon: Icon,
  children,
  ...props
}: {
  icon: React.ComponentType<{ className?: string }>
  children: React.ReactNode
} & React.ComponentProps<typeof Button>) {
  return (
    <Button {...props}>
      <Icon className="mr-2 h-4 w-4" />
      {children}
    </Button>
  )
}

// Add new variants
const customButtonVariants = cva(buttonVariants(), {
  variants: {
    rounded: {
      full: "rounded-full",
      none: "rounded-none",
    },
  },
})
```

### Form Patterns

```tsx
import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import { z } from "zod"
import { Button } from "@/components/ui/button"
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"

const formSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

export function LoginForm() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      email: "",
      password: "",
    },
  })

  function onSubmit(values: z.infer<typeof formSchema>) {
    console.log(values)
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input placeholder="email@example.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Submit</Button>
      </form>
    </Form>
  )
}
```

### Dialog Patterns

```tsx
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"

export function ConfirmDialog({
  children,
  onConfirm,
}: {
  children: React.ReactNode
  onConfirm: () => void
}) {
  return (
    <Dialog>
      <DialogTrigger asChild>{children}</DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Are you sure?</DialogTitle>
          <DialogDescription>This action cannot be undone.</DialogDescription>
        </DialogHeader>
        <Button onClick={onConfirm}>Confirm</Button>
      </DialogContent>
    </Dialog>
  )
}

// Usage
<ConfirmDialog onConfirm={() => deleteUser()}>
  <Button variant="destructive">Delete</Button>
</ConfirmDialog>
```

### Table Patterns

```tsx
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"

export function DataTable({ data }: { data: User[] }) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Name</TableHead>
          <TableHead>Email</TableHead>
          <TableHead>Role</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {data.map((user) => (
          <TableRow key={user.id}>
            <TableCell>{user.name}</TableCell>
            <TableCell>{user.email}</TableCell>
            <TableCell>{user.role}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
```

## Theming

### CSS Variables Approach

```css
/* app/globals.css */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    /* ... */
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
    /* ... */
  }
}
```

### Using Theme Colors

```tsx
// Use semantic colors
<div className="bg-background text-foreground">
<Button className="bg-primary text-primary-foreground">
<div className="border border-border">

// Not hardcoded colors
❌ <div className="bg-white text-black dark:bg-slate-900 dark:text-white">
✅ <div className="bg-background text-foreground">
```

### Custom Tailwind Config

```typescript
// tailwind.config.ts
import type { Config } from "tailwindcss"

const config: Config = {
  darkMode: ["class"],
  content: [
    "./pages/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./app/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        // Custom colors
        brand: {
          50: "#f0f9ff",
          500: "#0ea5e9",
          900: "#0c4a6e",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}

export default config
```

## Common Layouts

### Dashboard

```tsx
<div className="flex min-h-screen">
  {/* Sidebar */}
  <aside className="w-64 border-r bg-background">
    <nav className="p-4 space-y-2">
      {/* Nav items */}
    </nav>
  </aside>

  {/* Main */}
  <div className="flex-1 flex flex-col">
    {/* Header */}
    <header className="border-b h-16 flex items-center px-6">
      {/* Header content */}
    </header>

    {/* Content */}
    <main className="flex-1 overflow-auto p-6">
      {children}
    </main>
  </div>
</div>
```

### Card Grid

```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {items.map((item) => (
    <div
      key={item.id}
      className="border rounded-lg p-6 hover:shadow-lg transition-shadow"
    >
      <h3 className="font-semibold text-lg mb-2">{item.title}</h3>
      <p className="text-muted-foreground">{item.description}</p>
    </div>
  ))}
</div>
```

### Centered Container

```tsx
<div className="min-h-screen flex items-center justify-center bg-slate-50">
  <div className="w-full max-w-md p-6 bg-white rounded-lg shadow-lg">
    <h1 className="text-2xl font-bold mb-6">Sign In</h1>
    {/* Form */}
  </div>
</div>
```

## Performance Tips

```tsx
// ❌ Don't use @apply excessively
.button {
  @apply px-4 py-2 bg-blue-500 text-white rounded;
}

// ✅ Use utilities directly
<button className="px-4 py-2 bg-blue-500 text-white rounded">

// ✅ Extract component for reuse
<Button>Click me</Button>

// Purge unused styles (automatic with tailwind.config.ts content)
content: [
  "./app/**/*.{js,ts,jsx,tsx}",
  "./components/**/*.{js,ts,jsx,tsx}",
]
```

## Best Practices

1. **Use cn() for conditional classes** - Handles conflicts properly
2. **Semantic colors over hardcoded** - `bg-background` not `bg-white`
3. **Mobile-first responsive** - Start small, scale up with md:/lg:
4. **Component variants with CVA** - Type-safe, maintainable variants
5. **Dark mode from start** - Add dark: variants early
6. **Arbitrary values sparingly** - Prefer standard utilities
7. **Don't fight Tailwind** - Use utilities, not custom CSS
8. **Group related utilities** - Layout, then spacing, then colors
