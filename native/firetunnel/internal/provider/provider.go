package provider

import "context"

type Protocol struct {
	Name   string `json:"name"`
	Host   string `json:"host"`
	Port   int    `json:"port"`
	Scheme string `json:"scheme,omitempty"`
}

type Server struct {
	Hostname    string     `json:"hostname"`
	Port        int        `json:"port"`
	Quarantined bool       `json:"quarantined"`
	Protocols   []Protocol `json:"protocols,omitempty"`
}

type City struct {
	Name    string   `json:"name"`
	Code    string   `json:"code"`
	Servers []Server `json:"servers"`
}

type Country struct {
	Name   string `json:"name"`
	Code   string `json:"code"`
	Cities []City `json:"cities"`
}

type Provider interface {
	Name() string
	Locations(context.Context) ([]Country, error)
}

