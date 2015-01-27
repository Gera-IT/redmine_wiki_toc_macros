module TocMacros
  Redmine::WikiFormatting::Macros.register do
    desc "Displays a list of child pages"
    macro :wiki_toc do |obj, args|
      params = TocMacros.parse_params(args)
      allowed_fields = [:title, :created_at, :modified_at, :by_author, :by_parent, :"!title", :"!created_at", :"!modified_at", :"!by_author", :"!by_parent"]
      sort_by = params[:sort].to_sym if  allowed_fields.include?(params[:sort].to_sym)
      sort_by = sort_by || :title
      current_obj = obj.page
      @@o = "<ul>"



      TocMacros.get_ancestors(current_obj, sort_by, params[:depth].to_i)
      @@o << "</ul>"
      @@o.html_safe
      end



    end

  class << self

    def get_ancestors(page, sort_by, depth)
      return if page.children.empty?
      return if depth == 0
      page.children.eval(TocMacros.sort_relations[sort_by]).each do |child_wiki_page|
        TocMacros.generate_html_for_page(page.project, child_wiki_page)
        if page.children.last == child_wiki_page
          depth = depth -1
        end
        # TocMacros.generate_list(child, sort_by)
        get_ancestors(child_wiki_page, sort_by, depth)
      end
    end

    def generate_list(page, sort_by)
      @@o << '<ul>'
      page.children.eval(TocMacros.sort_relations[sort_by]).each do |child|
        @@o << TocMacros.generate_html_for_page(page.project, child)
      end
      @@o << "</ul>"
    end


    def collection_for_pages(wiki_page)
      wiki_page.childen
    end

    def generate_html_for_page(project, wiki_page)
      @@o << "<li style='margin-left: #{wiki_page.ancestors.count*5}px'>"
      @@o << "<a href=#{Rails.application.routes.url_helpers.project_wiki_page_path(project.identifier, wiki_page.title)}>#{wiki_page.pretty_title}</a>"
      @@o << "</li>"
    end

    def sort_relations
      relations = {
          :"title" => 'reorder("title ASC")',
          :"created_at" => 'reorder("created_at ASC")',
          :"modified_at" => "joins(:content).reorder('wiki_contents.updated_on ASC')",
          :"by_author"=> "joins(:content).reorder('wiki_contents.author_id ASC')",
          :"by_parent" => "reorder('parent_id ASC')",
          :"!title" => 'reorder("title DESC")',
          :"!created_at" => 'reorder("created_at DESC")',
          :"!modified_at" => "joins(:content).reorder('wiki_contents.updated_on DESC')",
          :"!by_author" => "joins(:content).reorder('wiki_contents.author_id DESC')",
          :"!by_parent" => "reorder('parent_id DESC')"

      }
      relations
    end

    def parse_params(array)
      params = {}
      array.each do |param|
        param = param.split("=")
        params[param.first.to_sym] = param.last if param.count == 2
      end
      params
    end

  end





end