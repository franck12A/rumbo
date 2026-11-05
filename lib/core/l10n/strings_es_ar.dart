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

  static const navCategories = 'Categorías';

  static const activeTabLabel = 'Activas';

  static const archivedTabLabel = 'Archivadas';

  static const restoreAction = 'Restaurar';

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

  static const incomeSourceRestoreDuplicateError =
      'No se puede restaurar: ya existe una fuente activa con ese nombre.';

  static const incomeSourceRestoredMessage = 'Fuente restaurada.';

  static const incomeSourcesArchivedEmptyTitle =
      'No hay fuentes de ingreso archivadas';

  static const incomeSourcesArchivedEmptySubtitle =
      'Cuando archives una fuente, va a aparecer acá.';

  static const categoriesTitle = 'Categorías';

  static const categoriesAdd = 'Agregar';

  static const categoriesEmptyTitle = 'Todavía no hay categorías';

  static const categoriesEmptySubtitle =
      'Agregá categorías de gasto, por ejemplo "Materiales" o '
      '"Transporte".';

  static const categoriesErrorTitle = 'No pudimos cargar las categorías.';

  static const categoriesGenericError = 'Algo salió mal. Probá de nuevo.';

  static const categoriesArchivedEmptyTitle = 'No hay categorías archivadas';

  static const categoriesArchivedEmptySubtitle =
      'Cuando archives una categoría, va a aparecer acá.';

  static const categoryCreateTitle = 'Nueva categoría';

  static const categoryEditTitle = 'Editar categoría';

  static const categoryNameLabel = 'Nombre';

  static const categoryNameHint = 'Ej.: Materiales';

  static const categoryColorLabel = 'Color';

  static const categoryEditTooltip = 'Editar';

  static const categoryArchiveTooltip = 'Archivar';

  static const categoryArchiveTitle = 'Archivar categoría';

  static const categoryArchiveAction = 'Archivar';

  static const categoryArchivedMessage = 'Categoría archivada.';

  static const categoryRestoredMessage = 'Categoría restaurada.';

  static const categoryNameEmptyError = 'El nombre no puede estar vacío.';

  static const categoryNameTooLongError =
      'El nombre puede tener hasta 40 caracteres.';

  static const categoryNameDuplicateError =
      'Ya existe una categoría activa con ese nombre.';

  static const categoryRestoreDuplicateError =
      'No se puede restaurar: ya existe una categoría activa con ese nombre.';

  static const saveAction = 'Guardar';

  static const cancelAction = 'Cancelar';

  static const retryAction = 'Reintentar';

  static const undoAction = 'Deshacer';

  static String incomeSourceArchiveBody(String name) =>
      '¿Archivar "$name"? No se borra, podés deshacerlo desde el aviso.';

  static String categoryArchiveBody(String name) =>
      '¿Archivar "$name"? No se borra, podés deshacerlo desde el aviso.';
}
