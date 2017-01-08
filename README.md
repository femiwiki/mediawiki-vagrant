# 미디어위키 설치 스크립트

설치하는 소프트웨어:

* PHP 7
* MariaDB 10
* Apache 2
* Mediawiki 1.28
* Restbase
* Parsoid

설치하는 추가 기능들:

* BetaFeatures
* Cite
* CodeEditor
* Description2
* Echo
* EmbedVideo
* GoogleRichCards
* Flow
* OpenGraphMeta
* ParserFunction
* Renameuser
* Scribunto
* SimpleMathJax
* SyntaxHighlight)GeSHi
* Thanks
* UserMerge
* VisualEditor
* WikiEditor

# 설치하기

웹 서버 설치하기:

    vagrant up www
    vagrant ssh www
    /vagrant/www/setup.sh

Parsoid 설치하기(시각편집기 서버):

    vagrant up parsoid
    vagrant ssh parsoid
    /vagrant/parsoid/setup.sh

브라우저로 http://192.168.50.10/ 접속

