-- Enable RLS on project_links table
ALTER TABLE project_links ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own project links
-- (links belonging to projects they own through resume_sections)
CREATE POLICY "Users can view own project links" ON project_links
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM projects p
      JOIN resume_sections rs ON p.section_id = rs.id
      JOIN resumes r ON rs.resume_id = r.id
      WHERE p.id = project_links.project_id
      AND r.user_id = auth.uid()
    )
  );

-- Policy: Users can insert links for their own projects
CREATE POLICY "Users can insert own project links" ON project_links
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM projects p
      JOIN resume_sections rs ON p.section_id = rs.id
      JOIN resumes r ON rs.resume_id = r.id
      WHERE p.id = project_links.project_id
      AND r.user_id = auth.uid()
    )
  );

-- Policy: Users can update their own project links
CREATE POLICY "Users can update own project links" ON project_links
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM projects p
      JOIN resume_sections rs ON p.section_id = rs.id
      JOIN resumes r ON rs.resume_id = r.id
      WHERE p.id = project_links.project_id
      AND r.user_id = auth.uid()
    )
  );

-- Policy: Users can delete their own project links
CREATE POLICY "Users can delete own project links" ON project_links
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM projects p
      JOIN resume_sections rs ON p.section_id = rs.id
      JOIN resumes r ON rs.resume_id = r.id
      WHERE p.id = project_links.project_id
      AND r.user_id = auth.uid()
    )
  );
