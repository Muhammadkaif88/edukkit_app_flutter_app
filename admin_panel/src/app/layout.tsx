import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import Link from "next/link";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Admin Panel | Edukkit",
  description: "Admin portal for Edukkit platform",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="min-h-screen bg-gray-50 flex font-sans">
        {/* Sidebar */}
        <aside className="w-64 bg-white border-r shadow-sm flex flex-col">
          <div className="h-16 flex items-center px-6 border-b">
            <h1 className="text-xl font-bold text-gray-800">Admin Panel</h1>
          </div>
          <nav className="p-4 space-y-2 flex-1">
            <Link href="/" className="block px-4 py-2 text-sm font-medium text-blue-600 bg-blue-50 rounded-md">
              Dashboard
            </Link>
            <Link href="/users" className="block px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 rounded-md transition-colors">
              Users
            </Link>
            <Link href="/courses" className="block px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 rounded-md transition-colors">
              Courses
            </Link>
            <Link href="/store" className="block px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 rounded-md transition-colors">
              Store
            </Link>
            <Link href="/settings" className="block px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50 rounded-md transition-colors">
              Settings
            </Link>
          </nav>
        </aside>

        {/* Main Content Area */}
        <main className="flex-1 flex flex-col">
          <header className="h-16 bg-white border-b flex items-center justify-between px-8 shadow-sm">
            <h2 className="text-xl font-semibold text-gray-800">Overview</h2>
            <div className="flex items-center space-x-4">
              <button className="text-sm text-gray-600 hover:text-gray-800">Notifications</button>
              <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold shadow-sm">
                A
              </div>
            </div>
          </header>
          
          <div className="p-8 flex-1 overflow-auto">
            {children}
          </div>
        </main>
      </body>
    </html>
  );
}
