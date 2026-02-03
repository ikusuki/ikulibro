class ContactsController < ApplicationController

  def send_contact
    nombre = params[:name].to_s
    email = params[:email].to_s
    comments = params[:comments].to_s

    if ENV["RESEND_API_KEY"].to_s.empty?
      render plain: "Servicio de email no configurado. Falta RESEND_API_KEY.", status: 500
      return
    end

    ResendClient.send_order(
      name: nombre,
      email: email,
      comments: comments
    )

    msg = "<h3>¡Muchas gracias!! ¡¡Email recibido!!</h3> <br/>¡¡Lo leo y me pongo en contacto contigo ya mismo, ya verás!"
    render json: msg, status: 200 and return
  rescue StandardError => e
    Rails.logger.error("Contact send failed: #{e.class} #{e.message}")
    render plain: "No se pudo enviar el email. Inténtalo de nuevo en unos minutos.", status: 502
  end
end
