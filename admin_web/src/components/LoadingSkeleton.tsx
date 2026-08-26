import React from 'react';

export const CardSkeleton: React.FC = () => (
  <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-2xs animate-pulse space-y-3">
    <div className="flex justify-between items-center">
      <div className="h-3 w-24 bg-slate-200 rounded"></div>
      <div className="w-8 h-8 rounded-lg bg-slate-100"></div>
    </div>
    <div className="h-7 w-32 bg-slate-200 rounded"></div>
    <div className="h-3 w-40 bg-slate-100 rounded"></div>
  </div>
);

export const TableSkeleton: React.FC<{ rows?: number }> = ({ rows = 5 }) => (
  <div className="divide-y divide-slate-100 animate-pulse">
    {Array.from({ length: rows }).map((_, i) => (
      <div key={i} className="p-4 sm:px-6 flex items-center justify-between gap-4">
        <div className="flex items-center gap-3 flex-1">
          <div className="w-10 h-10 rounded-lg bg-slate-200 shrink-0"></div>
          <div className="space-y-2 flex-1 max-w-sm">
            <div className="h-3.5 bg-slate-200 rounded w-3/4"></div>
            <div className="h-2.5 bg-slate-100 rounded w-1/2"></div>
          </div>
        </div>
        <div className="h-6 w-20 bg-slate-100 rounded-md shrink-0"></div>
        <div className="h-6 w-16 bg-slate-200 rounded-md shrink-0"></div>
      </div>
    ))}
  </div>
);

export const Spinner: React.FC<{ size?: 'sm' | 'md' | 'lg' }> = ({ size = 'md' }) => {
  const sizeClasses = {
    sm: 'w-4 h-4 border-2',
    md: 'w-6 h-6 border-2',
    lg: 'w-8 h-8 border-3',
  };
  return (
    <div
      className={`${sizeClasses[size]} border-indigo-600 border-t-transparent rounded-full animate-spin`}
    />
  );
};
