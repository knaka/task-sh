import React from 'react';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body bgcolor='#b0b0b0'>{children}</body>
    </html>
  );
}
