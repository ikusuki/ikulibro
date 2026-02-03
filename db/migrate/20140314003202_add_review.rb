class AddReview < ActiveRecord::Migration
  def change
    Review.create(name: "Eduardo", review: "Buenas tardes, más bien mañanas para ti Óscar:

 Llegó el libro, aunque ya tenía el PDF, pero tras unas pocas páginas, preferí esperar y leerlo en papel.
 Lo primero enhorabuena por la magnífica presentación, ilustraciones y calidad general.
 Lo segundo y a costa de robarte un poco de tu tiempo, que con tu Chiaki y el bombón de Kota, seguro tienes mejores cosas en que ocupar la jornada.

No puedo dejar de comentar las dos páginas de la dedicatoria de Arantzazu. Impresionante lo que transmite, la gente buena merece buenos amigos, pero encontrar esos tesoros es cuestión de azar y no siempre se presenta. Dice tanto de la calidad humana de ese intercambio de vivencias que realmente emociona.
 Sólo por esas dos páginas ( y por supuesto, por lo que me queda por descubrir ), ya era imprescindible que publicases tus sueños.
 Imagino que no debo ser el lector típico de tu blog, ni de tu libro. Tengo un hijo trabajando en ingeniería dos años en Alemania y me gustaría que encontrase un Norte como el tuyo si va a quedarse lejos de su ambiente.
 Lo dicho enhorabuena por tu obra y por ser como eres.

 Un abrazo a toda tu familia:

        Eduardo.")
  end
end
