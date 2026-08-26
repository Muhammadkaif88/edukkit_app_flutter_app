import React, { useState } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { Sidebar } from '../components/Sidebar';
import { Navbar } from '../components/Navbar';

export const AdminLayout: React.FC = () => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const location = useLocation();

  const getPageTitle = (pathname: string) => {
    if (pathname === '/') return 'Dashboard Overview';
    if (pathname.startsWith('/courses')) return 'Course Catalog & Pricing';
    if (pathname.startsWith('/curriculum')) return 'Curriculum & Lessons';
    if (pathname.startsWith('/videos')) return 'Bunny Video Studio';
    if (pathname.startsWith('/store')) return 'Store & Inventory Management';
    if (pathname.startsWith('/orders')) return 'Order Fulfillment & Shipping';
    if (pathname.startsWith('/users')) return 'User Accounts & Roles';
    if (pathname.startsWith('/entitlements')) return 'Course Access Entitlements';
    if (pathname.startsWith('/analytics')) return 'Commerce & Sales Analytics';
    if (pathname.startsWith('/settings')) return 'System & Security Settings';
    return 'Admin Portal';
  };

  return (
    <div className="min-h-screen bg-slate-50 flex">
      {/* Sidebar Drawer */}
      <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />

      {/* Main Container */}
      <div className="flex-1 lg:pl-64 flex flex-col min-w-0">
        <Navbar
          onOpenSidebar={() => setSidebarOpen(true)}
          title={getPageTitle(location.pathname)}
        />

        <main className="flex-1 p-4 sm:p-6 lg:p-8 max-w-7xl w-full mx-auto animate-in fade-in duration-150">
          <Outlet />
        </main>
      </div>
    </div>
  );
};
