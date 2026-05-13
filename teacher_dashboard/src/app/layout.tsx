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
  title: "Teacher Portal | Edukkit",
  description: "Teacher portal for Edukkit platform",
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
      <body className="min-h-screen bg-slate-50 flex font-sans">
        {/* Sidebar */}
        <aside className="w-64 bg-slate-900 text-white shadow-xl flex flex-col">
          <div className="h-16 flex items-center px-6 border-b border-slate-700">
            <h1 className="text-xl font-bold text-white">Teacher Portal</h1>
          </div>
          <nav className="p-4 space-y-2 flex-1">
            <Link href="/" className="block px-4 py-2 text-sm font-medium text-white bg-slate-800 rounded-md">
              Dashboard
            </Link>
            <Link href="/my-courses" className="block px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800 rounded-md transition-colors">
              My Courses
            </Link>
            <Link href="/students" className="block px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800 rounded-md transition-colors">
              Students
            </Link>
            <Link href="/earnings" className="block px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800 rounded-md transition-colors">
              Earnings
            </Link>
            <Link href="/assignments" className="block px-4 py-2 text-sm font-medium text-slate-300 hover:bg-slate-800 rounded-md transition-colors">
              Assignments
            </Link>
          </nav>
        </aside>

        {/* Main Content Area */}
        <main className="flex-1 flex flex-col">
          <header className="h-16 bg-white border-b flex items-center justify-between px-8 shadow-sm">
            <h2 className="text-xl font-semibold text-slate-800">Welcome back, Instructor!</h2>
            <div className="flex items-center space-x-4">
              <button className="text-sm text-slate-600 hover:text-slate-800 transition-colors">Alerts</button>
              <div className="w-10 h-10 rounded-full border-2 border-indigo-500 overflow-hidden bg-indigo-100 flex items-center justify-center font-bold text-indigo-700">
                I
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
