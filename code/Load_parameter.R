
######## Generate a datatable summarizing values 
# For environments (parameters), all values/variables are shown

showSimpleDT = function( dataToShow, rownames = TRUE, colnames = "Value")
{
  valuesDF = NULL;
  
  if(is.environment( dataToShow))
  {
    # Extract values from environment as character strings
    envValues = sapply(lapply(dataToShow, function(x) {ifelse(is.null(x), "NULL", x)}), paste, collapse = ", ");
    # Sort them by name and convert to data.frame
    valuesDF = data.frame("Value" = envValues[order(names(envValues))]);
  } else
  {
    valuesDF = dataToShow;
  }
  
  # Create a datatable with collected information
  # Create datatable
  DT::datatable( as.data.frame(valuesDF), 
                 class = "compact",
                 rownames = rownames,
                 colnames = colnames,
                 options = list(dom = "<'row'rt>", # Set elements for CSS formatting ('<Blf><rt><ip>')
                                autoWidth = FALSE,
                                columnDefs = list( # Center all columns
                                  list( targets = "_all",
                                        className = 'dt-center')),
                                orderClasses = FALSE, # Disable flag for CSS to highlight columns used for ordering (for performance)
                                ordering = FALSE,
                                paging = FALSE, # Disable pagination (show all)
                                processing = TRUE, 
                                scrollCollapse = TRUE,
                                scroller = TRUE,  # Only load visible data
                                scrollX = TRUE,
                                scrollY = "525px",
                                stateSave = TRUE));
}


######## 
