class GenerateAdventureJob < ApplicationJob
  queue_as :ai_generation
  
  # Nombre de tentatives en cas d'échec
  retry_on Faraday::Error, wait: :exponentially_longer, attempts: 3
  
  # En cas d'échec définitif, enregistrer l'erreur
  discard_on StandardError do |job, error|
    Rails.logger.error("Échec de la génération d'aventure: #{error.message}")
    # On pourrait également envoyer une notification à l'utilisateur ici
  end

  # @param user_id [Integer] ID de l'utilisateur qui a demandé la génération
  # @param prompt [String] Prompt utilisateur pour la génération d'aventure
  # @param callback_url [String] URL optionnelle pour notifier une fois terminé
  def perform(user_id, prompt, callback_url = nil)
    user = User.find(user_id)
    
    # Appel au service ema-ai
    ai_service = EmaAiService.new
    result = ai_service.generate_adventure(prompt)
    
    if result[:error].present?
      Rails.logger.error("Erreur API ema-ai: #{result[:error]} - #{result[:message]}")
      raise StandardError, "Erreur API ema-ai: #{result[:error]}"
    end
    
    # Création d'une nouvelle aventure avec les données générées par l'IA
    adventure = user.adventures.create!(
      title: result["title"],
      description: result["description"],
      location: result["location"],
      tags: result["tags"].join(","),
      difficulty: result["difficulty"],
      duration: result["duration"],
      distance: result["distance"]
    )
    
    # Si une URL de callback est fournie, notifier que la génération est terminée
    if callback_url.present?
      notify_completion(callback_url, adventure.id)
    end
    
    # Retourner l'aventure créée
    adventure
  end
  
  private
  
  def notify_completion(callback_url, adventure_id)
    Faraday.post(callback_url, { adventure_id: adventure_id }.to_json, 'Content-Type' => 'application/json')
  rescue Faraday::Error => e
    Rails.logger.error("Échec de notification: #{e.message}")
    # On ne relance pas d'erreur ici pour ne pas faire échouer le job
    # L'aventure a été créée avec succès, seule la notification a échoué
  end
end
