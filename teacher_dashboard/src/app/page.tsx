export default function DashboardPage() {
  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-xl shadow-md border border-slate-100 hover:shadow-lg transition-shadow">
          <h3 className="text-sm font-semibold text-slate-500 uppercase tracking-wider">Total Students</h3>
          <p className="text-4xl font-black text-indigo-600 mt-2">342</p>
          <div className="mt-4 text-sm text-green-600 flex items-center">
            <span>↑ 12% from last month</span>
          </div>
        </div>
        <div className="bg-white p-6 rounded-xl shadow-md border border-slate-100 hover:shadow-lg transition-shadow">
          <h3 className="text-sm font-semibold text-slate-500 uppercase tracking-wider">Active Courses</h3>
          <p className="text-4xl font-black text-indigo-600 mt-2">5</p>
          <div className="mt-4 text-sm text-slate-500 flex items-center">
            <span>Across 3 categories</span>
          </div>
        </div>
        <div className="bg-white p-6 rounded-xl shadow-md border border-slate-100 hover:shadow-lg transition-shadow">
          <h3 className="text-sm font-semibold text-slate-500 uppercase tracking-wider">Total Earnings</h3>
          <p className="text-4xl font-black text-green-600 mt-2">₹45,200</p>
          <div className="mt-4 text-sm text-slate-500 flex items-center">
            <span>Pending payout: ₹12,500</span>
          </div>
        </div>
      </div>

      <div className="mt-8 bg-white p-6 rounded-xl shadow-md border border-slate-100">
        <h3 className="text-lg font-bold text-slate-800 mb-4">Recent Activity</h3>
        <ul className="space-y-4">
          <li className="flex items-center justify-between p-4 bg-slate-50 rounded-lg hover:bg-slate-100 transition-colors">
            <div>
              <p className="font-semibold text-slate-700">New Enrollment in "Arduino Robotics 101"</p>
              <p className="text-sm text-slate-500">John Doe just purchased your course.</p>
            </div>
            <span className="text-xs font-bold text-slate-400 bg-slate-200 px-2 py-1 rounded">2h ago</span>
          </li>
          <li className="flex items-center justify-between p-4 bg-slate-50 rounded-lg hover:bg-slate-100 transition-colors">
            <div>
              <p className="font-semibold text-slate-700">Assignment Submitted</p>
              <p className="text-sm text-slate-500">3 students submitted "Line Follower Logic".</p>
            </div>
            <span className="text-xs font-bold text-slate-400 bg-slate-200 px-2 py-1 rounded">5h ago</span>
          </li>
        </ul>
      </div>
    </div>
  );
}
