class EmaAiService
  attr_reader :api_url
  
  def initialize(api_url = nil)
    @api_url = api_url || ENV['EMA_AI_API_URL'] || 'http://localhost:8000'
  end
  
  # Génère des recommandations d'aventures basées sur un prompt utilisateur
  # @param prompt [String] Le prompt utilisateur (ex: "Je cherche une randonnée près de Bordeaux")
  # @return [Hash] Les données de l'aventure générée ou une erreur
  def generate_adventure(prompt)
    endpoint = "#{@api_url}/api/generate"
    
    begin
      response = Faraday.post(endpoint) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = { prompt: prompt }.to_json
      end
      
      if response.status == 200
        JSON.parse(response.body)
      else
        { error: "Erreur API: #{response.status}", message: response.body }
      end
    rescue Faraday::Error => e
      { error: "Erreur de connexion", message: e.message }
    rescue JSON::ParserError => e
      { error: "Erreur de parsing JSON", message: e.message }
    end
  end
  
  # Recherche des aventures similaires basées sur un texte
  # @param query [String] Le texte de recherche
  # @return [Array] Liste des aventures similaires ou une erreur
  def search_similar(query)
    endpoint = "#{@api_url}/api/search"
    
    begin
      response = Faraday.get(endpoint) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.params = { query: query }
      end
      
      if response.status == 200
        JSON.parse(response.body)
      else
        { error: "Erreur API: #{response.status}", message: response.body }
      end
    rescue Faraday::Error => e
      { error: "Erreur de connexion", message: e.message }
    rescue JSON::ParserError => e
      { error: "Erreur de parsing JSON", message: e.message }
    end
  end
end 