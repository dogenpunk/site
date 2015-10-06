BUILD = build
RES = resources/public
SRC = src/thi/ng/site

MAIN = $(BUILD)/main
MAIN_TARGET = s3://thi.ng/
MAIN_SRC = $(SRC)/main

HTML_OPTS = --remove-surrounding-spaces max

main-html: $(MAIN)/index.html
main-js: $(MAIN)/js/main/app.js
main-css: $(MAIN)/css/style.css
main-fonts: $(MAIN)/fonts
main-img: $(MAIN)/img

$(MAIN)/index.html: $(RES)/index.html
	@echo "compressing html..."
	@mkdir -p $(MAIN)
	@htmlcompressor $(HTML_OPTS) -o $(MAIN)/index.html $(RES)/index.html

$(MAIN)/css/style.css: $(RES)/css/style.css
	@echo "compressing css..."
	@mkdir -p $(MAIN)/css
	@cleancss -o $(MAIN)/css/style.css $(RES)/css/style.css

$(MAIN)/fonts: $(RES)/fonts
	@echo "copying fonts..."
	@mkdir -p $(MAIN)/fonts
	@cp -R $(RES)/fonts/ $(MAIN)/fonts

$(MAIN)/img: $(RES)/img $(RES)/favicon.ico
	@echo "copying images..."
	@cp -R $(RES)/img/ $(MAIN)/img
	@cp $(RES)/favicon.ico $(MAIN)/

$(MAIN)/js/main/app.js: $(MAIN_SRC)
	@echo "compiling js..."
	@lein with-profile prod do clean, cljsbuild once min
	@mkdir -p $(MAIN)/js/main
	@cp $(RES)/js/main/app.js $(MAIN)/js/main/

main: main-html main-js main-css main-fonts main-img

install-main: main
	@echo "syncing with: $(MAIN_TARGET)"
	@s3cmd -P sync $(MAIN)/ $(MAIN_TARGET)

clean:
	@echo "cleaning..."
	@rm -rf $(BUILD)

serve-main:
	@sleep 1 && open "http://localhost:8000/" &
	@cd $(MAIN) && python3 -m http.server

.PHONY: clean serve-main
