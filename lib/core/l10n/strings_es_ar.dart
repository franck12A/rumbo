/// Textos visibles al usuario, en español (Argentina).
///
/// Están centralizados acá para que los widgets no hardcodeen copy y para
/// poder migrar a `gen-l10n` sin tocar la UI.
abstract final class AppStrings {
  static const appName = 'Rumbo';

  static const homeTitle = 'Rumbo';

  static const homeSubtitle =
      'Ingresos, gastos y metas de ahorro en un solo lugar.';

  static const navHome = 'Inicio';

  static const navIncomeSources = 'Fuentes de ingreso';

  static const incomeSourcesTitle = 'Fuentes de ingreso';

  static const incomeSourcesAdd = 'Agregar';

  static const incomeSourcesEmptyTitle = 'Todavía no hay fuentes de ingreso';

  static const incomeSourcesEmptySubtitle =
      'Agregá de dónde entra la plata, por ejemplo "Restaurante" o '
      '"Reparación de pelotas".';

  static const incomeSourcesErrorTitle =
      'No pudimos cargar las fuentes de ingreso.';

  static const incomeSourcesGenericError = 'Algo salió mal. Probá de nuevo.';

  static const incomeSourceCreateTitle = 'Nueva fuente de ingreso';

  static const incomeSourceEditTitle = 'Editar fuente de ingreso';

  static const incomeSourceNameLabel = 'Nombre';

  static const incomeSourceNameHint = 'Ej.: Reparación de pelotas';

  static const incomeSourceColorLabel = 'Color';

  static const incomeSourceEditTooltip = 'Editar';

  static const incomeSourceArchiveTooltip = 'Archivar';

  static const incomeSourceArchiveTitle = 'Archivar fuente de ingreso';

  static const incomeSourceArchiveAction = 'Archivar';

  static const incomeSourceArchivedMessage = 'Fuente archivada.';

  static const incomeSourceNameEmptyError = 'El nombre no puede estar vacío.';

  static const incomeSourceNameTooLongError =
      'El nombre puede tener hasta 40 caracteres.';

  static const incomeSourceNameDuplicateError =
      'Ya existe una fuente activa con ese nombre.';

  static const saveAction = 'Guardar';

  static const cancelAction = 'Cancelar';

  static const retryAction = 'Reintentar';

  static const undoAction = 'Deshacer';

  static String incomeSourceArchiveBody(String name) =>
      '¿Archivar "$name"? No se borra, podés deshacerlo desde el aviso.';
}
