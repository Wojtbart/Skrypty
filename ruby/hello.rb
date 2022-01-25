require 'nokogiri'
require 'open-uri'
require 'rubygems'

# do allegro i amazona nie działa, trzeba się łączyć do api

produkt="laptop" # szukana rzecz

url="https://www.ebay.pl/sch/i.html?_from=R40&_trksid=m570.l1313&_nkw= %s &_sacat=0" % [produkt]
headers = {'Accept-Language' => 'en-US,en;q=0.9'}

html=URI.open(url,headers)

doc = Nokogiri::HTML(html.read)
doc.encoding = 'utf-8'

arr=[]  # tu trzymam wszystkie moje produkty 

arr2=[] # tu zapisuje podstrony

puts "\nPobieram produkty z Ebaya dla słowa "+ produkt +" (wyświetlam tylko 3 z nich)"

info=doc.css('div.s-item__info.clearfix').each do |elm| 

    arr.push("Opis: "+elm.at_css("h3.s-item__title").text.strip + "\n")
    arr.push("Cena: "+elm.css("div.s-item__detail.s-item__detail--primary span.s-item__price").text.strip+"\n")
    arr.push("Stan: "+elm.css("div.s-item__subtitle span.SECONDARY_INFO").text.strip+"\n")
    arr.push("Koszt wysyłki: "+ elm.css("span.s-item__shipping.s-item__logisticsCost").text.strip+"\n")
    arr.push("Wysyłka "+elm.css("span.s-item__location.s-item__itemLocation").text.strip+"\n\n")

    arr2.append(elm.css("a.s-item__link")[0]["href"]+"\n\n")   
end

# usuwam pierwsze 5 wpisów
for i in 0..4 do 
    arr.shift
end

# wyswietlam 3 pierwsze produkty 
for i in 0..14 do 
    puts arr[i]
end

time = Time.now
dataPlik=time.strftime("%m-%d-%Y-%H-%M-%S")

File.open(dataPlik, "w+") do |f|
    arr2.each { |element| f.puts(element) }
end

puts "Zapisałem linki do pliku o nazwie:  %s \n\n" % [dataPlik]

puts "Wyświetlam przykładowego linka do podstrony z prodkuktem i związany z nim opis:\n"
url2=arr2[1]

html2=URI.open(url2,headers)

doc2 = Nokogiri::HTML(html2.read)
doc2.encoding = 'utf-8'

info2=doc2.css('div.c-std.vi-ds3cont-box-marpad.watch-redesign.new-brdr-btns').each do |elm|  

    puts "CENA(EURO): "+elm.css("span#prcIsum").text.strip  
end

info3=doc2.css('div#SRPSection').each do |elm|

    puts "Znajduje sie w "+elm.css("div.iti-eu-bld-gry")[0].text.strip
    puts "Dostawa: "+elm.css("span.vi-acc-del-range").text 
end

info4=doc2.css('h1.it-ttl > text()').each do |elm| 
    puts elm.text   
end


# puts "KONIEC!"

