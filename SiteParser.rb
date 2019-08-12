require 'nokogiri'
require 'mechanize'

module SiteParser
  def melon(url)
    detail = {}
    # アクセス
    charset = nil
    html = open(url) do |f|
        charset = f.charset
        f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    # 年齢認証確認
    if doc.at('//div[@id="main"]//div') == nil then
      url += "&adult_view=1"
      html = open(url) do |f|
        charset = f.charset
        f.read
      end
      doc = Nokogiri::HTML.parse(html, nil, charset)
    end
    # 情報回収
    detail[:cover] = "https:" + doc.at('//div[@id="main"]//div[@class="clm clm_l thumb"]//a')["href"]
    detail_table = doc.xpath('//div[@id="description"]//table//tr')
    detail[:title] = detail_table[0].at('.//td').text
    detail[:circle] = detail_table[1].at('.//td//a').text
    detail_table[2].xpath('.//td//a').each_with_index do |obj, i|
      if obj.attr("href") == "#" then
        next
      end
      if i == 0 then
        detail[:author] = obj.text
      else
        detail[:author] += ","+obj.text
      end
    end
    detail_table[3].xpath('.//td//a').each_with_index do |obj, i|
      if obj.attr("href") == "#" then
        next
      end
      if i == 0 then
        detail[:genre] = obj.text
      else
        detail[:genre] += ","+obj.text
      end
    end
    detail[:published_at] = detail_table[4].at('.//td').text.tr("/","-")
    if detail_table[6].at('.//th').text ==  "イベント" then
      detail[:event] = detail_table[6].at('.//td//a').text
      detail[:is_adult] = (detail_table[7].at('.//td').text == "18禁") ? true : false
    else
      detail[:event] = detail_table[7].at('.//td//a').text
      detail[:is_adult] = (detail_table[8].at('.//td').text == "18禁") ? true : false
    end
    p detail
    return detail
  end

  def tora(url)
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
    detail[:is_adult] = (doc.at('//*[@id="main"]//div//section//div[1]//div[2]//div//div[2]//span[@class="i-item mk-rating"]') != nil) ? true : false
    detail[:title] = doc.at('//*[@id="main"]//div//section//div[1]//div[2]//div//div[1]//h1//span').text
    detail_table = doc.xpath('//*[@id="main"]//div//section//div[3]//div[4]//div//section//div//table//tr')
    detail[:circle] = detail_table[0].at('.//td//span//a//span').text
    detail[:author] = detail_table[1].at('.//td//span//a//span').text
    detail[:genre] = detail_table[2].at('.//td//span//a//span').text
    if detail_table[3].at('.//td[1]').text == "発行日" then
      detail[:published_at] = detail_table[3].at('.//td//span//a//span').text.tr("/","-")
    else
      detail_table[3].xpath('.//td//span//a//span').each_with_index do |obj, i|
        if obj.attr("href") == "#" then
          next
        end
        if i == 0 then
          detail[:tag] = obj.text
        else
          detail[:tag] += ","+obj.text
        end
      end
      detail[:published_at] = detail_table[4].at('.//td//span//a//span').text.tr("/","-")
    end
    if detail_table[5].at('.//td[1]').text == "初出イベント" then
      detail[:event] = detail_table[5].at('.//td//span//a//span').text.split("　")[1].split("（")[0]
    else
      detail[:event] = detail_table[6].at('.//td//span//a//span').text.split("　")[1].split("（")[0]
    end
    return detail
  end

  def lashin(url)
    detail = {}
    # アクセス
    agent = Mechanize.new
    agent.user_agent = 'Linux Firefox'
    agent.get('https://shop.lashinbang.com/age_check')
    html = agent.get(url).content.toutf8
    doc = Nokogiri::HTML(html, nil, 'utf-8')
    # 情報回収
    detail[:cover] = doc.at('//*[@id="zoom_03"]')["src"]
    detail_area = doc.xpath('//*[@id="item_data"]//div[1]//dl')
    detail[:circle] = detail_area[0].at('.//dd//a').text
    detail_area[1].xpath('.//dd//a').each_with_index do |obj, i|
      if obj.attr("href") == "#" then
        next
      end
      if i == 0 then
        detail[:author] = obj.text
      else
        detail[:author] += ","+obj.text
      end
    end
    detail_area[2].xpath('.//dd//a').each_with_index do |obj, i|
      if obj.attr("href") == "#" then
        next
      end
      if i == 0 then
        detail[:genre] = obj.text
      else
        detail[:genre] += ","+obj.text
      end
    end
    title_area = doc.at('//*[@id="item_data"]//div[2]')
    detail[:is_adult] = (title_area.at('.//span').text == "18禁") ? true : false
    detail[:title] = title_area.at('.//h1').text
    detail_table = doc.xpath('//*[@id="item_data"]//table//tr')
    detail[:published_at] = detail_table[2].at('.//td').text.tr("年月","-").tr("日","")
    detail[:event] = detail_table[6].at('.//td//a').text.split('/')[0]
    return detail
  end

  module_function :melon
  module_function :tora
  module_function :lashin
end