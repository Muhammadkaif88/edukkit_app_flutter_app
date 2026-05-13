from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from ..database import Base

class Lesson(Base):
    __tablename__ = "lessons"

    id = Column(Integer, primary_key=True, index=True)
    course_id = Column(Integer, ForeignKey("courses.id"))
    title = Column(String, index=True)
    video_stream_id = Column(String)
    duration = Column(Integer) # in seconds
    notes_pdf = Column(String, nullable=True)
    order_index = Column(Integer, default=0)

    course = relationship("Course", back_populates="lessons")
