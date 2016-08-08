# HACK: https://github.com/shanemcd/monologue-markdown/commit/aedc7f7334c3e8d06e12ba70456feb6ab08c7c10
# Rails4にアップデートするためのハック
module Monologue::PostDecorator
end

Monologue::Post.class_eval do
  before_validation do
    if self.new_record?
      self.is_markdown = true
    end
  end

  def is_markdown?
    self.is_markdown == true
  end

  def content
    if self.is_markdown? && !in_admin?(caller)
      pipeline = Content::Pipeline.new
      return pipeline.filter(read_attribute(:content), markdown: { type: :gfm, safe: false })
    end
    read_attribute(:content)
  end

  def in_admin? caller
    caller.each do |c|
      return true if c.include? "app/controllers/monologue/admin/posts_controller.rb"
    end
    return false
  end
end
