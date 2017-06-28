package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"io"
	"net/http"
)

// templates is a collection of views for rendering with the renderTemplate function
// see homeHandler for an example
var templates *template.Template

func ArchiveUrlHandler(w http.ResponseWriter, r *http.Request) {
	done := func(err error) {}
	res, _, err := ArchiveUrl(appDB, r.FormValue("url"), done)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		io.WriteString(w, fmt.Sprintf("archive url '%s' error: %s", r.FormValue("url"), err.Error()))
		return
	}

	data, err := json.MarshalIndent(res.Url, "", "  ")
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		io.WriteString(w, fmt.Sprintf("error marshalling url json: %s", err.Error()))
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write(data)
}

// WebappHandler renders the home page
func WebappHandler(w http.ResponseWriter, r *http.Request) {
	renderTemplate(w, "webapp.html")
}

func CertbotHandler(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, cfg.CertbotResponse)
}

func HandleWebsocketUpgrade(w http.ResponseWriter, r *http.Request) {
	serveWs(room, w, r)
}

// renderTemplate renders a template with the values of cfg.TemplateData
func renderTemplate(w http.ResponseWriter, tmpl string) {
	err := templates.ExecuteTemplate(w, tmpl, map[string]interface{}{
		"ENV":             cfg.Mode,
		"title":           cfg.Title,
		"segmentApiToken": cfg.SegmentApiToken,
		"webappScripts":   cfg.WebappScripts,
	})
	if err != nil {
		log.Info(err.Error())
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
