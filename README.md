# Crawler
# This repo will download all of books on https://sachvui.com and save it in this repo

### file_path: data/category/book_name/chap_number.txt

## Run
```
mix gets.dep
```

```
iex -S mix
```

```
Crawler.SachVui.Book.download
```
## Note
- I have crawled category, url of books and save it at `data/book_links.txt`, data/`category_links.txt` as binary file, so when you run `Crawler.SachVui.Book.download`, this will get all links from `data/book_links` then with each link, `crawler` will get content of all chapters and save it.

- You can check content of three files `book_links.txt`, `category.txt`, `category_links.txt` with below code:
```
# book_links
File.read!('data/book_links.txt') |> :erlang.binary_to_term()

# category_links
File.read!('data/category_links.txt') |> :erlang.binary_to_term()

# category
File.read!('data/category.txt')
```

- Directory struct example
```
|-- Data
     |-- Novel/ # category
     |    |-- war_and_peace/ # book's name
     |    |    |-- chap1.txt # chapter   
     |    |    |-- chap2.txt   
     |    |    |-- chap3.txt   
     |    |-- lord of the rings/
     |         |-- chap1.txt   
     |         |-- chap2.txt   
     |         |-- chap3.txt   
     |-- Short story/ 
     |    |-- Man v. nature /
     |         |-- chap1.txt   
     |         |-- chap2.txt   
     |         |-- chap3.txt   
     |.....
```

## How crawler work
![crawler](/data/crawl_sachvui.png)


