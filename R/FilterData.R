#' Filter data using variance, coefficient of variation, or sparsity.
#'
#' @param xdata the data matrix
#' @param ydata feature labels/values
#' @param col_var_percentile_filter double to use as lower percentile to use for filtering cols by variance. Uses percentile from
#' histogram breaks.
#' @param row_var_percentile_filter double to use as lower percentile to use for filtering rows by variance. Uses percentile from
#' histogram breaks.
#' @param col_coeffvar_percentile_filter double to use as lower percentile to use for filtering cols by coefficient of variation. Uses percentile from
#' histogram breaks.
#' @param row_coeffvar_percentile_filter double to use as lower percentile to use for filtering rows by coefficient of variation. Uses percentile from
#' histogram breaks.
#' @param col_sparsity_min_nonzero_percentile double to use as lower percentile to use for filtering columns by sparsity. Uses percentile from
#' histogram breaks.
#' @param row_sparsity_min_nonzero_percentile double to use as lower percentile to use for filtering rows by sparsity. Uses percentile from
#' histogram breaks.
#' @param remove_zero_median_cols logical for whether to remove cols with median = 0
#' @param remove_zero_median_rows logical for whether to remove rows with median = 0
#' @param scale_zeroes_directly double to use for replacing zeros in data matrix
#' @param remove_zero_sd_cols logical for whether to filter features with zero std dev.
#' @export

FilterData = function(xdata, ydata,
                      col_var_percentile_filter = 0,
                      row_var_percentile_filter = 0,
                      col_coeffvar_percentile_filter = 0,
                      row_coeffvar_percentile_filter = 0,
                      col_sparsity_min_nonzero_percentile = 0,
                      row_sparsity_min_nonzero_percentile = 0,
                      remove_zero_median_cols = F,
                      remove_zero_median_rows = F,
                      scale_zeroes_directly = 0,
                      remove_zero_sd_cols = T) {

  remove_indices_safely = function(data, indices, varname,
                                   row_indices = F, col_indices = F) {
    if (length(indices) > 0) {
      # if there are no matching indices, we get indices = integer(0)
      # and if we use those, like df[, -integer(0)] we remove all columns
      data = as.matrix(data)

      if (col_indices) {
        data = data[, -indices]
      }

      if (row_indices) {
        data = data[-indices, ]
      }

    } else {
      # output an error message and return unedited data
      cat("\n Argument for ", substitute(varname), "=", varname, " has no matching indices \n")
    }
    return(data)
  }

  y_correct_order <- match(rownames(xdata), rownames(ydata))

  # we may not have labeled y values, if not just print a message
  if (any(!is.na(y_correct_order))) {
    ydata <- ydata[y_correct_order]
    # fix ydata rownames
    ydata <- as.matrix(ydata)
    rownames(ydata) <- rownames(xdata)

  } else {
    cat("\n Y does not have labels. Assuming Y and X have rows in the same order \n")
  }

  if (col_sparsity_min_nonzero_percentile == 0 && remove_zero_median_cols == T) {
    col_sparsity_min_nonzero_percentile = 0.5
  }

  if (row_sparsity_min_nonzero_percentile == 0 && remove_zero_median_rows == T) {
    row_sparsity_min_nonzero_percentile = 0.5
  }

  if (scale_zeroes_directly > 0) {
    x_zeros = which(x == 0)
    x[x_zeros] = scale_zeroes_directly
  }

  if (remove_zero_sd_cols) {
    # remove zero SD too
    zero_sd <- which(apply(xdata, 2, sd) == 0)

    if (length(zero_sd) > 0) {
      xdata = xdata[, -zero_sd]
    }
  }


  if (col_sparsity_min_nonzero_percentile > 0) {

    col_nonzero = apply(xdata, 2, function(x) length(which(x != 0)) / length(x))

    col_nonzero_hist = hist(col_nonzero, plot = F)
    col_nonzero_remove = which(col_nonzero > quantile(col_nonzero_hist$breaks, col_sparsity_min_nonzero_percentile))

    xdata = remove_indices_safely(xdata, col_nonzero_remove,
                                  col_sparsity_min_nonzero_percentile, col_indices = T)
  }


  if (col_var_percentile_filter > 0) {
    # filter column variance percentile
    colvars <- apply(xdata, 2, var)

    low_var_cols <- which(colvars < quantile(colvars, col_var_percentile_filter))

    xdata = remove_indices_safely(xdata, low_var_cols, col_var_percentile_filter, col_indices = T)
  }

  if (col_coeffvar_percentile_filter > 0) {
    col_coeffvar = apply(xdata, 2, function(x) sd(x)/mean(x))

    col_coeffvar_hist = hist(col_coeffvar, plot = F)

    low_col_coeff_vars = which(col_coeffvar > quantile(col_coeffvar_hist$breaks, col_coeffvar_percentile_filter))
    xdata = remove_indices_safely(xdata, low_col_coeff_vars, col_coeffvar_percentile_filter, col_indices = T)
  }


  if (row_sparsity_min_nonzero_percentile > 0) {
    # remove empty rows last
    row_nonzero = apply(xdata, 1, function(x) length(which(x != 0)) / length(x))

    # use percentile of histogram bins
    row_nonzero_hist = hist(row_nonzero, plot = F)
    row_nonzero_remove = which(row_nonzero > quantile(row_nonzero_hist$breaks, row_sparsity_min_nonzero_percentile))

    # check if we need to remove any rows
    xdata = remove_indices_safely(xdata, row_nonzero_remove,
                                  row_sparsity_min_nonzero_percentile, row_indices = T)
    ydata = remove_indices_safely(ydata, row_nonzero_remove,
                                  row_sparsity_min_nonzero_percentile, row_indices = T)
  }

  if (row_var_percentile_filter) {
    # remove empty rows last
    rowvars <- apply(xdata, 1, var)
    low_var_rows <- which(rowvars < quantile(rowvars, row_var_percentile_filter))

    # check if we need to remove any rows
    xdata = remove_indices_safely(xdata, low_var_rows,
                                  row_var_percentile_filter, row_indices = T)
    ydata = remove_indices_safely(ydata, low_var_rows,
                                  row_var_percentile_filter, row_indices = T)
  }

  if (row_coeffvar_percentile_filter > 0) {
    row_coeffvar = apply(xdata, 1, function(x) sd(x)/mean(x))

    row_coeffvar_hist = hist(row_coeffvar, plot = F)

    low_row_coeff_vars = which(row_coeffvar > quantile(row_coeffvar_hist$breaks, row_coeffvar_percentile_filter))

    xdata = remove_indices_safely(xdata, low_row_coeff_vars, row_coeffvar_percentile_filter, row_indices = T)
    ydata = remove_indices_safely(ydata, low_row_coeff_vars, row_coeffvar_percentile_filter, row_indices = T)

  }

  return(list("x" = xdata, "y" = ydata))
}
