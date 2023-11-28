library(ggplot2)
library(gridlayout)
library(bslib)
library(DT)
library(plotly)
library(preprocessCore) #normalize.quantiles 


options(shiny.maxRequestSize = 200*1024^2)
md.description <- readLines('www/Description.md')
source('R/functions.R')

ui <- grid_page(
  layout = c(
    "Logo     name    ",
    "Input  Output  ",
    "footnote footnote"
  ),
  row_sizes = c(
    "0.42fr",
    "2.16fr",
    "0.23fr"
  ),
  col_sizes = c(
    "325px",
    "1fr"
  ),
  gap_size = "1rem",
  grid_card(
    area = "Input",
    card_header("Input Gene Expression File"),
    card_body(
      fileInput(
        inputId = "fileInput",
        label = "Select Your Input File"
        ),
      markdown(
        mds = c(
          "<center>OR</center>"
        )
      ),
      actionButton(
        inputId = "defaultDataButton",
        label = "Load Example Data",
        width = "100%"
      )
    ),
    card_footer(
      actionButton(
        inputId = "submit",
        label = "Submit For Prediction",
        width = "100%"
      )
    )
  ),
  grid_card(
    area = "Logo",
    card_body(
      HTML("<p style=\"height: 1px\"></p>"), # blank line
      HTML("<h1><center><font color=#4F0433 size=20>LymphProg</font></center></h1>")
    )
  ),
  grid_card(
    area = "name",
    card_body(
      HTML("<p style=\"height: 200px\"></p>"), # blank line
      HTML("<h3><center>Lymphoma Prognostic prediction tool (v1.0)</center></h3>"),
      HTML("<center>A tool to predict the risk of experiencing refractory/relapse disease within two years in DLBCL patients treated with R-CHOP.</center>")
    )
  ),
  grid_card(
    area = "Output",
    card_body(
      tabsetPanel(
        tabPanel(
            title = "Description",
            markdown(mds = md.description)
          ),
        tabPanel(
              title = "Input data",
              DTOutput(outputId = "inputTable", width = "100%")
            ),
        tabPanel(
          title = "Prediction",
          grid_container(
            layout = c(
              "output plot",
              "output plot    "
            ),
            row_sizes = c(
              "0.27fr",
              "1.73fr"
            ),
            col_sizes = c(
              "1.03fr",
              "0.97fr"
            ),
            gap_size = "10px",
            grid_card(
              area = "output",
              card_body(
                downloadButton('downloadData',"Download Output Table", width = "50%"),
                DTOutput(outputId = "outputTable", width = "100%")
              )
            ),
            grid_card(
              area = "plot",
              card_body(plotOutput(outputId = "plot"))
            )
          )
        )
      )
    )
  ),
  grid_card(
    area = "footnote",
    card_body(
      gap = "0px",
      markdown(
        mds = c(
          "*Citation*: Ren W., Wan H., et al., Genetic and transcriptomic analyses of diffuse large B-cell lymphoma patients with poor outcomes within two years of diagnosis, Revision."
        )
      )
    )
  )
)


server <- function(input, output) {
  # Reactive -------
  file <- reactive({req(input$fileInput); input$fileInput}, label = 'custom')

  # Input file ---------
  df.input <- reactive({read_tsv(file()$datapath)})

  # View the input table-------
  output$inputTable <- renderDataTable({ 
    if (input$defaultDataButton) return(Example) else return(df.input())
    },
       options = list(pageLength = 10, autoWidth = T)
       )
  
  # Submit and run -------
  observeEvent(input$submit, {
    
    df.risk <- if (input$defaultDataButton) runRisk(Example) else runRisk(df.input())
    
    # View the output table  -------
    output$outputTable <- renderDataTable(df.risk$df_score)
    
    # Download table ------
    output$downloadData <- downloadHandler(
      filename = function(){paste("Risk_ouput.xls")},
      content = function(file){write_tsv(df.risk$df_score,file)}
    )
    
    #---- View the output plot  -------#
    output$plot <- renderPlot({df.risk$point})
    
    
  })
  

}

shinyApp(ui, server)


