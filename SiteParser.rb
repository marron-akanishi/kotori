require 'nokogiri'
require 'mechanize'

module SiteParser
  def melon(url)
    # URLチェック
    if url.index("https://www.melonbooks.co.jp/detail/detail.php?product_id=") != 0 &&
       url.index("https://www.melonbooks.co.jp/fromagee/detail/detail.php?product_id=") != 0 then
      return nil
    end
    detail = {}
    # アクセス
    charset = nil
    html = open(url + "&adult_view=1") do |f|
        charset = f.charset
        f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    # 情報回収
    cover_img_path = doc.at('//div[@class="item-body-wrap"]//div[@class="item-img"]//figure//a')
    if cover_img_path != nil then
      detail[:cover] = "https:" + cover_img_path["href"]
    else
      detail[:cover] = nil
    end
    detail[:title] = doc.at('//h1[@class="page-header"]').text
    detail_table = doc.xpath('//div[@class="item-detail __light"]//table//tr')
    detail_table.each do |row|
      case row.at('.//th').text.strip
      when "サークル名" then
        detail[:circle] = row.at('.//td//a').text.split("(作品数")[0].chop.strip
      when "作家名" then
        row.xpath('.//td//a').each_with_index do |obj, i|
          if obj.attr("href") == "#" then
            next
          end
          if i == 0 then
            detail[:author] = obj.text.strip
          else
            detail[:author] += ","+obj.text.strip
          end
        end
      when "ジャンル" then
        row.xpath('.//td//a').each_with_index do |obj, i|
          if obj.attr("href") == "#" then
            next
          end
          if i == 0 then
            detail[:genre] = obj.text.strip
          else
            detail[:genre] += ","+obj.text.strip
          end
        end
      when "発行日" then
        detail[:date] = row.at('.//td').text.strip.tr("/","-")
      when "イベント" then
        detail[:event] = row.at('.//td//a').text.strip
      when "作品種別" then
        detail[:is_adult] = (row.at('.//td').text.strip == "18禁") ? true : false
      end
    end
    detail[:url] = url.split("&")[0]
    return detail
  end

  def tora(url)
    # URLチェック
    if url.index("https://ecs.toranoana.jp/tora/ec/item/") != 0 &&
      url.index("https://ec.toranoana.jp/tora_r/ec/item/") != 0 then
      return nil
    end
    detail = {}
    # アクセス
    charset = nil
    html = open(url) do |f|
        charset = f.charset
        f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    # 情報回収
    detail[:cover] = doc.at('//div[@id="preview"]//a//img')["src"]
    detail[:is_adult] = doc.at('//span[@class="product-detail-label-item mk-rating"]') ? true : false
    detail[:title] = doc.at('//h1[@class="product-detail-desc-title"]//span').text
    detail_table = doc.xpath('//table[@class="product-detail-spec-table"]//tr')
    detail_table.each do |row|
      case row.at('.//td[1]').text.strip
      when "サークル名" then
        detail[:circle] = row.at('.//a[1]//span').text
      when "作家" then
        row.xpath('.//td[2]//a').each_with_index do |obj, i|
          if obj.attr("href") == "#" then
            next
          end
          if i == 0 then
            detail[:author] = obj.at('.//span').text
          else
            detail[:author] += ","+obj.at('.//span').text
          end
        end
      when "ジャンル/サブジャンル" then
        row.xpath('.//td[2]//a').each_with_index do |obj, i|
          if obj.attr("href") == "#" then
            next
          end
          if i == 0 then
            detail[:genre] = obj.at('.//span').text
          else
            detail[:genre] += ","+obj.at('.//span').text
          end
        end
      when "メインキャラ" then
        row.xpath('.//td[2]//a').each_with_index do |obj, i|
          if obj.attr("href") == "#" then
            next
          end
          if i == 0 then
            detail[:tag] = obj.at('.//span').text
          else
            detail[:tag] += ","+obj.at('.//span').text
          end
        end
      when "発行日" then
        detail[:date] = row.at('.//td[2]//a//span').text.tr("/","-")
      when "初出イベント" then
        detail[:event] = row.at('.//td[2]//a//span').text.split("　")[1].split("（")[0]
      end
    end
    detail[:url] = url
    return detail
  end

  def lashin(url)
    # URLチェック
    if url.index("https://shop.lashinbang.com/products/detail/") != 0 then
      return nil
    end
    detail = {}
    # アクセス
    agent = Mechanize.new
    agent.user_agent = 'Linux Firefox'
    agent.get('https://shop.lashinbang.com/age_check')
    html = agent.get(url).content
    doc = Nokogiri::HTML(html, nil, 'utf-8')
    # 情報回収
    detail[:cover] = doc.at('//*[@id="zoom_03"]')["src"]
    detail_area = doc.xpath('//*[@id="item_data"]//div[1]//dl')
    detail_area.each do |row|
      case row.at('.//dt').text.strip
      when "サークル：" then
        detail[:circle] = row.at('.//dd//a').text
      when "作家：" then
        row.xpath('.//dd//a').each_with_index do |obj, i|
          if obj.attr("href") == "#" then
            next
          end
          if i == 0 then
            detail[:author] = obj.text
          else
            detail[:author] += ","+obj.text
          end
        end
      when "作品：" then
        row.xpath('.//dd//a').each_with_index do |obj, i|
          if obj.attr("href") == "#" then
            next
          end
          if i == 0 then
            detail[:genre] = obj.text
          else
            detail[:genre] += ","+obj.text
          end
        end
      end
    end
    title_area = doc.at('//*[@id="item_data"]//div[2]')
    detail[:is_adult] = (title_area.at('.//span').text == "18禁") ? true : false
    detail[:title] = title_area.at('.//h1').text.split('【')[0]
    detail_table = doc.xpath('//*[@id="item_data"]//table//tr')
    detail_table.each do |row|
      case row.at('.//th').text.strip
      when "発行日" then
        detail[:date] = row.at('.//td').text.tr("年月","-").tr("日","")
      when "発売イベント" then
        detail[:event] = row.at('.//td//a').text.split('/')[0]
      end
    end
    detail[:url] = url
    return detail
  end

  module_function :melon
  module_function :tora
  module_function :lashin
end