class CategoriesDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :image_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Category.with_translations(I18n.locale).count,
      iTotalDisplayRecords: categories.total_entries,
      aaData: data
    }
  end

private

  def data
    categories.map do |category|
      [
        link_to(category.name, admin_category_path(:id => category.id, :locale => I18n.locale)),
        category.type_name,
        action_links(category)
      ]
    end
  end

  def action_links(category)
    x = ""
    x << link_to(I18n.t("helpers.links.edit"),
                    edit_admin_category_path(:id => category.id, :locale => I18n.locale), :class => 'btn btn-mini')
    x << " "
    x << link_to(I18n.t("helpers.links.destroy"),
                    admin_category_path(:id => category.id, :locale => I18n.locale),
                    :method => :delete,
								    :data => { :confirm => I18n.t("helpers.links.confirm") },
                    :class => 'btn btn-mini btn-danger')
    x << "<br /><br />"
    x << I18n.t('app.common.added_on', :date => I18n.l(category.created_at, :format => :short))
    return x.html_safe
  end

  def categories
    @categories ||= fetch_categories
  end

  def fetch_categories
    categories = Category.with_translations(I18n.locale).order("#{sort_column} #{sort_direction}")
    categories = categories.page(page).per_page(per_page)
    if params[:sSearch].present?
      search_qry = "category_translations.name like :search "  
      categories = categories.where(search_qry, search: "%#{params[:sSearch]}%")
    end
    categories
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[category_translations.name categories.type_id categories.created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
