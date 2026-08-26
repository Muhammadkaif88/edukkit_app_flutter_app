import React, { useState, useEffect, useRef } from 'react';
import {
  Menu,
  Shield,
  ExternalLink,
  LogOut,
  ChevronDown,
  User,
  Activity,
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { Badge } from './Badge';
import { BASE_URL } from '../api/client';

interface NavbarProps {
  onOpenSidebar: () => void;
  title: string;
}

export const Navbar: React.FC<NavbarProps> = ({ onOpenSidebar, title }) => {
  const { profile, logout } = useAuth();
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [backendHealthy, setBackendHealthy] = useState<boolean | null>(null);
  const [latencyMs, setLatencyMs] = useState<number | null>(null);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Ping backend health
  useEffect(() => {
    const checkBackend = async () => {
      const start = performance.now();
      try {
        const res = await fetch(`${BASE_URL}/health`);
        const duration = Math.round(performance.now() - start);
        setLatencyMs(duration);
        setBackendHealthy(res.ok);
      } catch {
        setBackendHealthy(false);
      }
    };
    checkBackend();
    const interval = setInterval(checkBackend, 30000);
    return () => clearInterval(interval);
  }, []);

  // Click outside to close dropdown
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setUserMenuOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <header className="sticky top-0 z-30 h-16 bg-white border-b border-slate-200 px-4 sm:px-8 flex items-center justify-between shadow-2xs">
      <div className="flex items-center gap-3 min-w-0">
        <button
          onClick={onOpenSidebar}
          className="lg:hidden p-2 -ml-2 rounded-lg text-slate-500 hover:bg-slate-100 hover:text-slate-700 cursor-pointer"
          aria-label="Open sidebar"
        >
          <Menu size={20} />
        </button>
        <div className="min-w-0">
          <h2 className="text-base sm:text-lg font-bold text-slate-900 tracking-tight truncate">
            {title}
          </h2>
        </div>
      </div>

      <div className="flex items-center gap-2 sm:gap-4">
        {/* Backend Live Status Ping */}
        <div
          className="hidden md:flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-slate-50 border border-slate-200 text-xs font-medium text-slate-600"
          title={
            backendHealthy
              ? `FastAPI Backend Online (${latencyMs}ms)`
              : 'FastAPI Backend Disconnected'
          }
        >
          <span
            className={`w-2 h-2 rounded-full ${
              backendHealthy ? 'bg-emerald-500 animate-pulse' : 'bg-rose-500'
            }`}
          />
          <span className="font-semibold text-slate-700">
            {backendHealthy ? 'API Online' : 'API Offline'}
          </span>
          {latencyMs !== null && backendHealthy && (
            <span className="text-[10px] text-slate-400 font-mono">({latencyMs}ms)</span>
          )}
        </div>

        {/* Swagger Docs Link */}
        <a
          href={`${BASE_URL}/docs`}
          target="_blank"
          rel="noreferrer"
          className="hidden sm:flex items-center gap-1 px-2.5 py-1 text-slate-500 hover:text-indigo-600 hover:bg-indigo-50 border border-transparent hover:border-indigo-100 rounded-lg text-xs font-semibold transition-all"
        >
          <span>API Docs</span>
          <ExternalLink size={13} />
        </a>

        {/* Role Badge */}
        <Badge variant="purple" size="sm" className="hidden lg:inline-flex gap-1.5 items-center">
          <Shield size={12} />
          <span>{profile?.role?.toUpperCase() || 'ADMIN'}</span>
        </Badge>

        {/* User Menu Dropdown */}
        <div className="relative" ref={dropdownRef}>
          <button
            onClick={() => setUserMenuOpen(!userMenuOpen)}
            className="flex items-center gap-2.5 p-1 sm:p-1.5 rounded-lg hover:bg-slate-50 border border-transparent hover:border-slate-200 transition-all text-left cursor-pointer"
          >
            <div className="w-8 h-8 rounded-lg bg-gradient-to-tr from-indigo-600 to-indigo-500 text-white font-bold flex items-center justify-center text-xs shadow-2xs">
              {profile?.name?.charAt(0).toUpperCase() || 'A'}
            </div>
            <div className="hidden xl:block min-w-0">
              <p className="text-xs font-semibold text-slate-800 leading-none truncate max-w-[120px]">
                {profile?.name || 'Administrator'}
              </p>
              <p className="text-[10px] text-slate-400 mt-0.5 leading-none capitalize">
                {profile?.role || 'Admin'}
              </p>
            </div>
            <ChevronDown size={14} className="text-slate-400 hidden sm:block" />
          </button>

          {/* Dropdown Popover */}
          {userMenuOpen && (
            <div className="absolute right-0 mt-2 w-56 bg-white rounded-xl shadow-xl border border-slate-200 py-2 z-50 animate-in fade-in zoom-in-95 duration-150">
              <div className="px-4 py-2 border-b border-slate-100">
                <p className="text-xs font-bold text-slate-800 truncate">{profile?.name}</p>
                <p className="text-[11px] text-slate-500 truncate">{profile?.email}</p>
                <div className="mt-1.5">
                  <Badge variant="purple" size="sm">
                    {profile?.role?.toUpperCase() || 'ADMIN'}
                  </Badge>
                </div>
              </div>

              <div className="px-1 py-1">
                <a
                  href="/settings"
                  className="flex items-center gap-2 px-3 py-2 text-xs text-slate-700 hover:bg-slate-50 rounded-lg transition-colors"
                  onClick={() => setUserMenuOpen(false)}
                >
                  <User size={14} className="text-slate-400" />
                  <span>Account & System Settings</span>
                </a>
                <a
                  href={`${BASE_URL}/docs`}
                  target="_blank"
                  rel="noreferrer"
                  className="flex items-center justify-between px-3 py-2 text-xs text-slate-700 hover:bg-slate-50 rounded-lg transition-colors"
                >
                  <div className="flex items-center gap-2">
                    <Activity size={14} className="text-slate-400" />
                    <span>FastAPI OpenAPI</span>
                  </div>
                  <ExternalLink size={12} className="text-slate-400" />
                </a>
              </div>

              <div className="pt-1 border-t border-slate-100 px-1">
                <button
                  onClick={() => {
                    setUserMenuOpen(false);
                    logout();
                  }}
                  className="w-full flex items-center gap-2 px-3 py-2 text-xs text-rose-600 hover:bg-rose-50 rounded-lg transition-colors font-medium cursor-pointer"
                >
                  <LogOut size={14} />
                  <span>Sign Out</span>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};
