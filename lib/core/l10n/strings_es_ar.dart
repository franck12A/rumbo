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

  static const navTransactions = 'Movimientos';

  static const transactionsTitle = 'Movimientos';

  static const transactionsPreviousMonth = 'Mes anterior';

  static const transactionsNextMonth = 'Mes siguiente';

  static const transactionsCurrentMonth = 'Ir al mes actual';

  static const transactionsSummaryIncome = 'Ingresos';

  static const transactionsSummaryExpense = 'Gastos';

  static const transactionsSummaryBalance = 'Balance';

  static const transactionsNewIncome = 'Nuevo ingreso';

  static const transactionsNewExpense = 'Nuevo gasto';

  static const transactionsEmptyTitle = 'No hay movimientos este mes';

  static const transactionsEmptySubtitle =
      'Cargá un ingreso o un gasto para empezar.';

  static const transactionsErrorTitle = 'No pudimos cargar los movimientos.';

  static const transactionsGenericError = 'Algo salió mal. Probá de nuevo.';

  static const transactionCreateTitle = 'Nuevo movimiento';

  static const transactionEditTitle = 'Editar movimiento';

  static const transactionTypeIncome = 'Ingreso';

  static const transactionTypeExpense = 'Gasto';

  static const transactionAmountLabel = 'Monto';

  static const transactionAmountHint = 'Ej.: 10.000,00';

  static const transactionDateLabel = 'Fecha';

  static String transactionDateValue(String date) =>
      '$transactionDateLabel: $date';

  static const transactionSourceLabel = 'Fuente de ingreso';

  static const transactionCategoryLabel = 'Categoría';

  static const transactionReferenceHint = 'Seleccioná una opción';

  static const transactionNoteLabel = 'Nota (opcional)';

  static const transactionDeleteTooltip = 'Eliminar';

  static const transactionDeleteTitle = 'Eliminar movimiento';

  static const transactionDeleteAction = 'Eliminar';

  static const transactionDeleteBody =
      '¿Eliminar este movimiento? Podés deshacerlo desde el aviso.';

  static const transactionDeletedMessage = 'Movimiento eliminado.';

  static const transactionArchivedSuffix = '(archivada)';

  static const transactionAmountInvalidError =
      'Ingresá un monto válido, por ejemplo 10.000,00.';

  static const transactionAmountNotPositiveError =
      'El monto tiene que ser mayor que cero.';

  static const transactionNoteTooLongError =
      'La nota puede tener hasta 200 caracteres.';

  static const transactionSourceRequiredError = 'Elegí una fuente de ingreso.';

  static const transactionSourceUnexpectedError =
      'Un ingreso no lleva categoría.';

  static const transactionSourceNotFoundError =
      'La fuente de ingreso ya no existe.';

  static const transactionSourceArchivedError =
      'La fuente de ingreso está archivada. Elegí una activa.';

  static const transactionCategoryRequiredError = 'Elegí una categoría.';

  static const transactionCategoryUnexpectedError =
      'Un gasto no lleva fuente de ingreso.';

  static const transactionCategoryNotFoundError = 'La categoría ya no existe.';

  static const transactionCategoryArchivedError =
      'La categoría está archivada. Elegí una activa.';

  static const transactionNotFoundError = 'El movimiento ya no existe.';

  static const transactionNoIncomeSourcesTitle =
      'No hay fuentes de ingreso activas';

  static const transactionNoIncomeSourcesBody =
      'Agregá o restaurá una fuente para poder cargar ingresos.';

  static const transactionNoCategoriesTitle = 'No hay categorías activas';

  static const transactionNoCategoriesBody =
      'Agregá o restaurá una categoría para poder cargar gastos.';

  static const transactionGoToIncomeSources = 'Ir a Fuentes de ingreso';

  static const transactionGoToCategories = 'Ir a Categorías';

  static const monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  /// Indexed by [DateTime.weekday], so the first entry is unused.
  static const weekdayNames = [
    '',
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

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
