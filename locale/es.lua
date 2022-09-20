local Translations = {
     error = {
          need_more_exp = '¡Necesitas más experiencia para fabricar este objeto!',
          need_more_mat = 'No tienes suficientes materiales',
          crafting_is_restricted = 'La fabricación de este objeto está restringida',
          crafting_failed = '¡Fallo en la fabricacion! ^.^',
          not_authorized = 'No estás autorizado a hacer esto'
     },
     success = {
          successful_crafting = 'el crafting fue exitoso'
     },
     info = {
          mr = 'Sr.',
          mrs = 'Sra.',
     },
     mail = {
          sender = 'Empresa de fabricación',
          subject = 'Lista de Materiales',
          message = 'Estimado %s %s, <br /><br /> La lista de materiales que necesitas para elaborar (%s): <br /><br /> * Taza de exito: %d, <br /> * Restringido: %s <br />',
          level = ' * Nivel: %s <br />',
          yes = 'Si',
          no = 'No',
          tnx_message = '<br /><br />Nos alegramos de contar con tigo!',
          materials_list_header = '<br /># Lista de Materiales:',
          materials_list = '<br />- %s %dx'
     },
     menu = {
          back = 'Atras',
          leave = 'Dejar',
          player_crafting_information = 'Su información sobre la elaboración',
          -- craft menu
          item_name = 'Nombre de item',
          craft = 'Craft',
          check_mat_list = 'Chequeo de Lista de Materiales',

          -- player crafting information menu
          your_name = 'You nombre',
          your_job = 'tu Trabajo',
          job_sub = 'Nombre: %s | Grado: %s',
          crafting_exp = 'Su exp. de fabricación',

          -- main menu
          main_menu_header = 'Banco de trabajo de fabricación'
     }
}

Lang = Locale:new({
     phrases = Translations,
     warnOnMissing = true
})
