final _frontmatterRegex = RegExp(r'^---\n.*?\n---\n', dotAll: true);

/// Removes the YAML frontmatter block at the start of [markdown], if any.
String stripFrontmatter(String markdown) {
  return markdown.replaceFirst(_frontmatterRegex, '');
}
