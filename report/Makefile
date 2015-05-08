all: report

report: report.tex
	pdflatex report.tex

biblio: bibliography.bib report.aux
	bibtex report.aux
	pdflatex report.tex

clean:
	rm -f *.aux *.log *.pdf *.bbl *.blg *.toc
