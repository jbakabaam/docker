run:
	docker run -d -p 52777:22 -p 52778:8787 -p 52779:8888 --name bas bgb

build:
	docker build . -t bgb

stop:
	docker stop bas && docker rm bas

rebuild:
	docker stop bas && docker rm bas
	docker build . -t bgb
	
