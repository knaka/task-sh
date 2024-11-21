import { JSX } from 'hono/jsx'

export default function RootLayout({
  children,
}: {
  children: ReactElement ;
}) {
  return (
    <html lang="en">
      <body bgcolor='#b0FFFF'>{children}</body>
    </html>
  );
}
