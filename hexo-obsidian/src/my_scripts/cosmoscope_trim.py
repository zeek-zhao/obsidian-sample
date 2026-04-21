"""
  此脚本将根据 Cosma CLI 2.4.0 生成的关系图谱网页进行修剪。
  作者：uuanqin（wuanqin@mail.ustc.edu.cn）
"""

import os
import re

from bs4 import BeautifulSoup
import sys
from pathlib import Path

def trim(target_html):
    """
    修剪 HTML文件使之能在侧边栏展出
    :return:
    """

    soup = BeautifulSoup(open(target_html,"r",encoding="utf-8"), 'html.parser')

    # 删除多余元素
    soup.html.body.aside.decompose()
    soup.html.body.main.decompose()
    soup.html.body.button.decompose() # 2.4.0
    soup.html.body.button.decompose() # 2.4.0
    for div in soup.html.body.find_all("div", {'class': 'graph-controls'}):
        div.decompose()


    # 修改css，使得图片占据全画面
    style_str = soup.html.style.string
    style_str = re.sub(r"(width: )calc\(100vw - 30rem\)(;)",r"\1 100vw\2",style_str,count=1,flags=re.DOTALL)
    soup.html.style.string = style_str

    # 项目地址 https://codepen.io/jqueryalmeida/pen/ZxmzYe
    # CSS部分
    css_string = """
   .btn-b {
    position: absolute;
    bottom: 9%;
    right: 2%;
    cursor: pointer;
    font-size: 10px;
    text-align: left;
    background: #a188fc;
    background: linear-gradient(to right, #0f4eb4 1%, #07a1e9 100%);
    color: #ddffff;
    padding: 0rem 0rem 0rem 0rem;
    border-radius: 10rem 50rem 50rem 10rem;
    -webkit-transition: all 0.7s;
    -moz-transition: all 0.7s;
    transition: all 0.7s;
    display: flex;
    align-items: center;
    justify-content: space-between;
   }
   .btn-b:after {
    content: "";
    position: absolute;
    right: -1px;
    margin-left: 1em;
    width: 35px;
    height: 35px;
    border-radius: 50%;
    box-shadow: 0px 2px 8px 0px rgba(15, 78, 180, 0.22);
    background: #3bc1ff url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MTIgNTEyIj48IS0tISBGb250IEF3ZXNvbWUgUHJvIDYuNC4yIGJ5IEBmb250YXdlc29tZSAtIGh0dHBzOi8vZm9udGF3ZXNvbWUuY29tIExpY2Vuc2UgLSBodHRwczovL2ZvbnRhd2Vzb21lLmNvbS9saWNlbnNlIChDb21tZXJjaWFsIExpY2Vuc2UpIENvcHlyaWdodCAyMDIzIEZvbnRpY29ucywgSW5jLiAtLT48cGF0aCBkPSJNMzQ0IDBINDg4YzEzLjMgMCAyNCAxMC43IDI0IDI0VjE2OGMwIDkuNy01LjggMTguNS0xNC44IDIyLjJzLTE5LjMgMS43LTI2LjItNS4ybC0zOS0zOS04NyA4N2MtOS40IDkuNC0yNC42IDkuNC0zMy45IDBsLTMyLTMyYy05LjQtOS40LTkuNC0yNC42IDAtMzMuOWw4Ny04N0wzMjcgNDFjLTYuOS02LjktOC45LTE3LjItNS4yLTI2LjJTMzM0LjMgMCAzNDQgMHpNMTY4IDUxMkgyNGMtMTMuMyAwLTI0LTEwLjctMjQtMjRWMzQ0YzAtOS43IDUuOC0xOC41IDE0LjgtMjIuMnMxOS4zLTEuNyAyNi4yIDUuMmwzOSAzOSA4Ny04N2M5LjQtOS40IDI0LjYtOS40IDMzLjkgMGwzMiAzMmM5LjQgOS40IDkuNCAyNC42IDAgMzMuOWwtODcgODcgMzkgMzljNi45IDYuOSA4LjkgMTcuMiA1LjIgMjYuMnMtMTIuNSAxNC44LTIyLjIgMTQuOHoiLz48L3N2Zz4=) no-repeat center;
    background-size: 50%;
   }
    """
    new_style_tag = soup.new_tag("style")
    new_style_tag.string = css_string
    soup.html.head.append(new_style_tag)
    # HTML部分
    new_div_tag = soup.new_tag("div")
    new_div_tag["class"] = "btn-b"
    # 链接
    new_a_tag = soup.new_tag("a")
    new_a_tag["href"] = "/DO_NOT_render/cosmoscope/cosmoscope.html"
    new_a_tag["target"] = "_blank"
    new_a_tag.append(new_div_tag)
    soup.html.body.div.insert_after(new_a_tag)


    # 重新写回
    p = Path(target_html)
    output_html =  os.path.dirname(target_html)+"/"+p.stem+'_trim.html'

    with open(output_html,"w",encoding="utf-8") as f:
        f.write(soup.prettify())

if __name__ == "__main__":
    # target_html = "cosma_dir/cosmoscope.html"
    trim(sys.argv[1])
