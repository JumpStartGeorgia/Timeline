class CategorySweeper < ActionController::Caching::Sweeper
  require 'json_cache'
  observe Category # This sweeper is going to keep an eye on the Category model

  # If our sweeper detects that a Category was created call this
  def after_create(category)
    expire_cache_for(category)
  end

  # If our sweeper detects that a Category was updated call this
  def after_update(category)
    expire_cache_for(category)
  end

  # If our sweeper detects that a Category was deleted call this
  def after_destroy(category)
    expire_cache_for(category)
  end

  private
  def expire_cache_for(category)
Rails.logger.debug "............... clearing all cache because of change to categories"
    JsonCache.clear
  end
end
