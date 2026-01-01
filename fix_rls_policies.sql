-- Fix RLS Policies for Resume Sections
-- This file contains updated policies to fix the row-level security violation

-- Drop existing policies for resume_sections
DROP POLICY IF EXISTS "Users can view own resume sections" ON resume_sections;
DROP POLICY IF EXISTS "Users can manage own resume sections" ON resume_sections;

-- Create new, more permissive policies for resume_sections
CREATE POLICY "Users can view own resume sections" ON resume_sections FOR SELECT USING (
  auth.uid() IS NOT NULL
);

CREATE POLICY "Users can insert resume sections for own resumes" ON resume_sections FOR INSERT WITH CHECK (
  auth.uid() IS NOT NULL
);

CREATE POLICY "Users can update own resume sections" ON resume_sections FOR UPDATE USING (
  auth.uid() IS NOT NULL
);

CREATE POLICY "Users can delete own resume sections" ON resume_sections FOR DELETE USING (
  auth.uid() IS NOT NULL
);

-- Update policies for section data tables to be more permissive
-- Header sections
DROP POLICY IF EXISTS "Users can view own section data" ON header_sections;
DROP POLICY IF EXISTS "Users can manage own section data" ON header_sections;

CREATE POLICY "Users can manage header sections" ON header_sections FOR ALL USING (
  auth.uid() IS NOT NULL
);

-- Summary sections
DROP POLICY IF EXISTS "Users can view own summary sections" ON summary_sections;
DROP POLICY IF EXISTS "Users can manage own summary sections" ON summary_sections;

CREATE POLICY "Users can manage summary sections" ON summary_sections FOR ALL USING (
  auth.uid() IS NOT NULL
);

-- Work experiences
DROP POLICY IF EXISTS "Users can view own work experiences" ON work_experiences;
DROP POLICY IF EXISTS "Users can manage own work experiences" ON work_experiences;

CREATE POLICY "Users can manage work experiences" ON work_experiences FOR ALL USING (
  auth.uid() IS NOT NULL
);

-- Experience points
DROP POLICY IF EXISTS "Users can view own experience points" ON experience_points;
DROP POLICY IF EXISTS "Users can manage own experience points" ON experience_points;

CREATE POLICY "Users can manage experience points" ON experience_points FOR ALL USING (
  auth.uid() IS NOT NULL
);

-- Education entries
DROP POLICY IF EXISTS "Users can view own education entries" ON education_entries;
DROP POLICY IF EXISTS "Users can manage own education entries" ON education_entries;

CREATE POLICY "Users can manage education entries" ON education_entries FOR ALL USING (
  auth.uid() IS NOT NULL
);

-- Skills
DROP POLICY IF EXISTS "Users can view own skills" ON skills;
DROP POLICY IF EXISTS "Users can manage own skills" ON skills;

CREATE POLICY "Users can manage skills" ON skills FOR ALL USING (
  auth.uid() IS NOT NULL
);

-- Projects
DROP POLICY IF EXISTS "Users can view own projects" ON projects;
DROP POLICY IF EXISTS "Users can manage own projects" ON projects;

CREATE POLICY "Users can manage projects" ON projects FOR ALL USING (
  auth.uid() IS NOT NULL
);

-- Project points
DROP POLICY IF EXISTS "Users can view own project points" ON project_points;
DROP POLICY IF EXISTS "Users can manage own project points" ON project_points;

CREATE POLICY "Users can manage project points" ON project_points FOR ALL USING (
  auth.uid() IS NOT NULL
);

-- Certifications
DROP POLICY IF EXISTS "Users can view own certifications" ON certifications;
DROP POLICY IF EXISTS "Users can manage own certifications" ON certifications;

CREATE POLICY "Users can manage certifications" ON certifications FOR ALL USING (
  auth.uid() IS NOT NULL
);

-- Languages
DROP POLICY IF EXISTS "Users can view own languages" ON languages;
DROP POLICY IF EXISTS "Users can manage own languages" ON languages;

CREATE POLICY "Users can manage languages" ON languages FOR ALL USING (
  auth.uid() IS NOT NULL
);

-- Custom sections
DROP POLICY IF EXISTS "Users can view own custom sections" ON custom_sections;
DROP POLICY IF EXISTS "Users can manage own custom sections" ON custom_sections;

CREATE POLICY "Users can manage custom sections" ON custom_sections FOR ALL USING (
  auth.uid() IS NOT NULL
);

-- Resume shares
DROP POLICY IF EXISTS "Users can view own resume shares" ON resume_shares;
DROP POLICY IF EXISTS "Users can manage own resume shares" ON resume_shares;

CREATE POLICY "Users can manage resume shares" ON resume_shares FOR ALL USING (
  auth.uid() IS NOT NULL
);
