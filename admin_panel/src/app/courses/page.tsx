'use client';

import { useEffect, useState } from 'react';

const API_URL = "https://edukkit-api.edukkitofficial.workers.dev";

interface Course {
  id: string;
  title: string;
  instructor: string;
  price: number;
  is_published: boolean;
  category: string;
}

export default function CoursesPage() {
  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`${API_URL}/courses`)
      .then(res => res.json())
      .then(data => {
        setCourses(data.courses || []);
        setLoading(false);
      })
      .catch(err => {
        console.error("Error fetching courses:", err);
        setLoading(false);
      });
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold text-gray-800">Course Management</h2>
        <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors shadow-sm">
          + Create Course
        </button>
      </div>
      
      {loading ? (
        <div className="flex justify-center py-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {courses.map((course) => (
            <div key={course.id} className="bg-white rounded-lg shadow-sm border border-gray-100 overflow-hidden flex flex-col transition-shadow hover:shadow-md">
              <div className="h-32 bg-gray-200 flex items-center justify-center">
                <span className="text-gray-400 font-medium">Course Thumbnail</span>
              </div>
              <div className="p-5 flex-1 flex flex-col">
                <div className="flex justify-between items-start mb-2">
                  <h3 className="text-lg font-bold text-gray-800 line-clamp-1">{course.title}</h3>
                  <span className={`px-2 py-0.5 text-xs font-medium rounded-full ${course.is_published ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
                    {course.is_published ? 'Active' : 'Draft'}
                  </span>
                </div>
                <p className="text-sm text-gray-600 mb-4">Instructor: {course.instructor}</p>
                <p className="text-sm font-bold text-blue-600 mb-4">₹{course.price}</p>
                
                <div className="mt-auto flex justify-between items-center pt-4 border-t border-gray-100">
                  <span className="text-sm font-medium text-gray-500">{course.category}</span>
                  <div className="flex gap-2">
                    <button className="text-blue-600 hover:text-blue-800 text-sm font-medium transition-colors">Edit</button>
                    <button className="text-red-600 hover:text-red-800 text-sm font-medium transition-colors">Archive</button>
                  </div>
                </div>
              </div>
            </div>
          ))}
          {courses.length === 0 && (
            <div className="col-span-full text-center py-12 text-gray-500">
              No courses found. Add your first course to get started!
            </div>
          )}
        </div>
      )}
    </div>
  );
}
