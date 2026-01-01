-- Resume Builder Supabase Database Schema
-- Run these SQL commands in your Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Resumes table
CREATE TABLE IF NOT EXISTS resumes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL DEFAULT 'My Resume',
  template_name TEXT DEFAULT 'modern',
  is_public BOOLEAN DEFAULT false,
  is_favorite BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Resume sections table
CREATE TABLE IF NOT EXISTS resume_sections (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  resume_id UUID REFERENCES resumes(id) ON DELETE CASCADE NOT NULL,
  section_type TEXT NOT NULL CHECK (section_type IN ('header', 'summary', 'work_experience', 'education', 'skills', 'projects', 'certifications', 'languages', 'custom')),
  section_title TEXT NOT NULL,
  section_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Header section data
CREATE TABLE IF NOT EXISTS header_sections (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  section_id UUID REFERENCES resume_sections(id) ON DELETE CASCADE NOT NULL,
  full_name TEXT,
  email TEXT,
  phone_number TEXT,
  location TEXT,
  website TEXT,
  linkedin TEXT,
  github TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Summary section data
CREATE TABLE IF NOT EXISTS summary_sections (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  section_id UUID REFERENCES resume_sections(id) ON DELETE CASCADE NOT NULL,
  content TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Work experience entries
CREATE TABLE IF NOT EXISTS work_experiences (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  section_id UUID REFERENCES resume_sections(id) ON DELETE CASCADE NOT NULL,
  company TEXT NOT NULL,
  role TEXT NOT NULL,
  start_date TEXT,
  end_date TEXT,
  location TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Experience description points
CREATE TABLE IF NOT EXISTS experience_points (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  experience_id UUID REFERENCES work_experiences(id) ON DELETE CASCADE NOT NULL,
  point_text TEXT NOT NULL,
  point_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Education entries
CREATE TABLE IF NOT EXISTS education_entries (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  section_id UUID REFERENCES resume_sections(id) ON DELETE CASCADE NOT NULL,
  institution TEXT NOT NULL,
  degree TEXT,
  field_of_study TEXT,
  start_date TEXT,
  end_date TEXT,
  gpa TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Skills
CREATE TABLE IF NOT EXISTS skills (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  section_id UUID REFERENCES resume_sections(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  skill_level TEXT CHECK (skill_level IN ('beginner', 'intermediate', 'advanced', 'expert')),
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Projects
CREATE TABLE IF NOT EXISTS projects (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  section_id UUID REFERENCES resume_sections(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  technologies TEXT[], -- Array of technologies
  project_url TEXT,
  github_url TEXT,
  start_date TEXT,
  end_date TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Project description points
CREATE TABLE IF NOT EXISTS project_points (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE NOT NULL,
  point_text TEXT NOT NULL,
  point_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Certifications
CREATE TABLE IF NOT EXISTS certifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  section_id UUID REFERENCES resume_sections(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  issuer TEXT,
  issue_date TEXT,
  expiry_date TEXT,
  credential_id TEXT,
  credential_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Languages
CREATE TABLE IF NOT EXISTS languages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  section_id UUID REFERENCES resume_sections(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  proficiency TEXT CHECK (proficiency IN ('basic', 'conversational', 'professional', 'native')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Custom sections
CREATE TABLE IF NOT EXISTS custom_sections (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  section_id UUID REFERENCES resume_sections(id) ON DELETE CASCADE NOT NULL,
  content TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Resume sharing settings
CREATE TABLE IF NOT EXISTS resume_shares (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  resume_id UUID REFERENCES resumes(id) ON DELETE CASCADE NOT NULL,
  share_token TEXT UNIQUE NOT NULL,
  is_public BOOLEAN DEFAULT false,
  expires_at TIMESTAMP WITH TIME ZONE,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_resumes_user_id ON resumes(user_id);
CREATE INDEX IF NOT EXISTS idx_resume_sections_resume_id ON resume_sections(resume_id);
CREATE INDEX IF NOT EXISTS idx_resume_sections_type ON resume_sections(section_type);
CREATE INDEX IF NOT EXISTS idx_header_sections_section_id ON header_sections(section_id);
CREATE INDEX IF NOT EXISTS idx_work_experiences_section_id ON work_experiences(section_id);
CREATE INDEX IF NOT EXISTS idx_experience_points_experience_id ON experience_points(experience_id);
CREATE INDEX IF NOT EXISTS idx_education_entries_section_id ON education_entries(section_id);
CREATE INDEX IF NOT EXISTS idx_skills_section_id ON skills(section_id);
CREATE INDEX IF NOT EXISTS idx_projects_section_id ON projects(section_id);
CREATE INDEX IF NOT EXISTS idx_project_points_project_id ON project_points(project_id);
CREATE INDEX IF NOT EXISTS idx_certifications_section_id ON certifications(section_id);
CREATE INDEX IF NOT EXISTS idx_languages_section_id ON languages(section_id);
CREATE INDEX IF NOT EXISTS idx_resume_shares_token ON resume_shares(share_token);
CREATE INDEX IF NOT EXISTS idx_resume_shares_resume_id ON resume_shares(resume_id);

-- RLS (Row Level Security) Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE resumes ENABLE ROW LEVEL SECURITY;
ALTER TABLE resume_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE header_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE summary_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_experiences ENABLE ROW LEVEL SECURITY;
ALTER TABLE experience_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE education_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE certifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE resume_shares ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Resumes policies
CREATE POLICY "Users can view own resumes" ON resumes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own resumes" ON resumes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own resumes" ON resumes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own resumes" ON resumes FOR DELETE USING (auth.uid() = user_id);

-- Resume sections policies
CREATE POLICY "Users can view own resume sections" ON resume_sections FOR SELECT USING (
  EXISTS (SELECT 1 FROM resumes WHERE resumes.id = resume_id AND resumes.user_id = auth.uid())
);
CREATE POLICY "Users can manage own resume sections" ON resume_sections FOR ALL USING (
  EXISTS (SELECT 1 FROM resumes WHERE resumes.id = resume_id AND resumes.user_id = auth.uid())
);

-- All section data policies (linked through resume_sections)
CREATE POLICY "Users can view own section data" ON header_sections FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM resume_sections rs 
    JOIN resumes r ON r.id = rs.resume_id 
    WHERE rs.id = section_id AND r.user_id = auth.uid()
  )
);
CREATE POLICY "Users can manage own section data" ON header_sections FOR ALL USING (
  EXISTS (
    SELECT 1 FROM resume_sections rs 
    JOIN resumes r ON r.id = rs.resume_id 
    WHERE rs.id = section_id AND r.user_id = auth.uid()
  )
);

-- Apply similar policies for all section tables
CREATE POLICY "Users can view own summary sections" ON summary_sections FOR SELECT USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);
CREATE POLICY "Users can manage own summary sections" ON summary_sections FOR ALL USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);

CREATE POLICY "Users can view own work experiences" ON work_experiences FOR SELECT USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);
CREATE POLICY "Users can manage own work experiences" ON work_experiences FOR ALL USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);

CREATE POLICY "Users can view own experience points" ON experience_points FOR SELECT USING (
  EXISTS (SELECT 1 FROM work_experiences we JOIN resume_sections rs ON rs.id = we.section_id JOIN resumes r ON r.id = rs.resume_id WHERE we.id = experience_id AND r.user_id = auth.uid())
);
CREATE POLICY "Users can manage own experience points" ON experience_points FOR ALL USING (
  EXISTS (SELECT 1 FROM work_experiences we JOIN resume_sections rs ON rs.id = we.section_id JOIN resumes r ON r.id = rs.resume_id WHERE we.id = experience_id AND r.user_id = auth.uid())
);

CREATE POLICY "Users can view own education entries" ON education_entries FOR SELECT USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);
CREATE POLICY "Users can manage own education entries" ON education_entries FOR ALL USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);

CREATE POLICY "Users can view own skills" ON skills FOR SELECT USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);
CREATE POLICY "Users can manage own skills" ON skills FOR ALL USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);

CREATE POLICY "Users can view own projects" ON projects FOR SELECT USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);
CREATE POLICY "Users can manage own projects" ON projects FOR ALL USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);

CREATE POLICY "Users can view own project points" ON project_points FOR SELECT USING (
  EXISTS (SELECT 1 FROM projects p JOIN resume_sections rs ON rs.id = p.section_id JOIN resumes r ON r.id = rs.resume_id WHERE p.id = project_id AND r.user_id = auth.uid())
);
CREATE POLICY "Users can manage own project points" ON project_points FOR ALL USING (
  EXISTS (SELECT 1 FROM projects p JOIN resume_sections rs ON rs.id = p.section_id JOIN resumes r ON r.id = rs.resume_id WHERE p.id = project_id AND r.user_id = auth.uid())
);

CREATE POLICY "Users can view own certifications" ON certifications FOR SELECT USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);
CREATE POLICY "Users can manage own certifications" ON certifications FOR ALL USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);

CREATE POLICY "Users can view own languages" ON languages FOR SELECT USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);
CREATE POLICY "Users can manage own languages" ON languages FOR ALL USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);

CREATE POLICY "Users can view own custom sections" ON custom_sections FOR SELECT USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);
CREATE POLICY "Users can manage own custom sections" ON custom_sections FOR ALL USING (
  EXISTS (SELECT 1 FROM resume_sections rs JOIN resumes r ON r.id = rs.resume_id WHERE rs.id = section_id AND r.user_id = auth.uid())
);

-- Resume shares policies
CREATE POLICY "Users can view own resume shares" ON resume_shares FOR SELECT USING (
  EXISTS (SELECT 1 FROM resumes WHERE resumes.id = resume_id AND resumes.user_id = auth.uid())
);
CREATE POLICY "Users can manage own resume shares" ON resume_shares FOR ALL USING (
  EXISTS (SELECT 1 FROM resumes WHERE resumes.id = resume_id AND resumes.user_id = auth.uid())
);
CREATE POLICY "Anyone can view public resume shares" ON resume_shares FOR SELECT USING (is_public = true);

-- Functions and triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_resumes_updated_at BEFORE UPDATE ON resumes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_resume_sections_updated_at BEFORE UPDATE ON resume_sections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_header_sections_updated_at BEFORE UPDATE ON header_sections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_summary_sections_updated_at BEFORE UPDATE ON summary_sections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_work_experiences_updated_at BEFORE UPDATE ON work_experiences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_education_entries_updated_at BEFORE UPDATE ON education_entries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_skills_updated_at BEFORE UPDATE ON skills FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_certifications_updated_at BEFORE UPDATE ON certifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_languages_updated_at BEFORE UPDATE ON languages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_custom_sections_updated_at BEFORE UPDATE ON custom_sections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
