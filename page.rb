require './helpers'

class Page
  def self.create(page)
    return nil unless page["title"] and page["body"]

    next_id = $redis.incr("pages:next_id")
    $redis.sadd("pages:all", next_id)

    page["date"] = Time.now
    page["id"] = next_id
    page["sanitized_title"] = sanitize_string(page["title"])

    page.each_pair do |key, val|
      $redis.hset("pages:#{next_id}", key, val)
    end

    $redis.set("pages:by_title:#{page["sanitized_title"]}", next_id)

    return page
  end

  def self.save(page)
    old_page = Page.get_by_id(page["id"])
    self.delete_by_id(old_page["id"]) unless page["id"].nil?

    return Page.create(page)
  end

  def self.get_all
    pages = []
    $redis.smembers("pages:all").each do |n|
      pages << self.get_by_id(n)
    end

    return pages
  end

  def self.get_by_id(id)
    return $redis.hgetall("pages:#{id}") || {}
  end

  def self.get_by_title(name)
    page_id = $redis.get("pages:by_title:#{sanitize_string(name)}")
    return self.get_by_id(page_id)
  end

  def self.delete_by_id(id)
    $redis.srem("pages:all", id)
    $redis.del("pages:#{id}")
  end

  def self.delete_by_name(name)
    sane_name = sanitize_string(name)
    id = $redis.get("pages:by_title:#{sane_name}")

    $redis.del("pages:by_title:#{sane_name}")
    self.delete_by_id(id)
  end
end

