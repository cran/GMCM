library(shiny)
library(shinydashboard)
library(shinyBS)
library(knitr)
library(rhandsontable)
library(DT)
library(GMCM)

# General named list for method choices
method_choices <-
  c("Nelder-Mead" = "NM",
    "Simulated Annealing" = "SANN",
    "limited-memory quasi-Newton method" = "L-BFGS",
    "limited-memory quasi-Newton method with box constraints" = "L-BFGS-B",
    "Pseudo EM algorithm" = "PEM")

# Define UI for application
shinyUI(
  navbarPage(
    title = tagList(icon("box-open"), strong("GMCM")),
    windowTitle = "GMCM",
    theme = "bootstrap.css",
    inverse = TRUE,


    # File input tab ______________________________________________________ ----
    tabPanel(
      title = "File input",
      dashboardPage(
        dashboardHeader(disable = TRUE),
        dashboardSidebar(

          # * Input: File ----
          fileInput(inputId = "in_file",
                    label = list(
                      "Choose CSV File",
                      tipify(icon("question-circle"),
                             title = HTML(
                               "The input file should be a plain text file where columns",
                               "correspond to features/<wbr/>variables/<wbr/>experiments and",
                               "rows correspond to observations. I.e. you intend to cluster",
                               "rows and not columns."
                             ),
                             placement = "right",
                             trigger = "hover",
                             options = list(container = "body")
                      )
                    ),
                    multiple = FALSE,
                    accept = c("text/csv",
                               "text/comma-separated-values,text/plain",
                               ".csv")),
          # File input options for read.csv
          conditionalPanel(
            condition = "output.in_file_uploaded",

            # * Input: header checkbox ----
            checkboxInput("header", "Header", TRUE),

            # * Input: select separator ----
            radioButtons(inputId = "sep",
                         label = "Separator",
                         choices = c("Comma" = ",",
                                     "Semicolon" = ";",
                                     "Tabs" = "\t"),
                         selected = ";"),

            # * Input: select quotes ----
            radioButtons(inputId = "quote",
                         label = "Quotes",
                         choices = c(None = "",
                                     "Double Quote" = '"',
                                     "Single Quote" = "'"),
                         selected = '"')
          )

        ),
        dashboardBody(
          uiOutput("in_file_data_box"),
          uiOutput("model_cols_box"),
          uiOutput("raw_data_box")

        )
      )
    ),




    # General model _______________________________________________________ ----
    tabPanel(
      title = "General GMCM",
      dashboardPage(
        dashboardHeader(disable = TRUE),
        dashboardSidebar(
          sidebarMenu(

            menuItem(
              text = "Fit model",
              icon = icon("tachometer"),
              startExpanded = FALSE,

              # * Input: Start parameters ----
              menuItem(
                text = "Start parameters",
                icon = icon("chevron-circle-right"),

                # Content
                numericInput(inputId = "full_m",
                             label = "Number of components (m)",
                             value = 2, min = 2, step = 1),

                selectInput(inputId = "full_rtheta_method",
                            label = "Random theta method",
                            choices = eval(formals(rtheta)$method),
                            selected = eval(formals(rtheta)$method)[2]),

                actionButton(inputId = "full_random_theta",
                             label = "Randomize theta",
                             icon = icon("dice-one"))


              ),

              # * Input: Addtional parameters ----
              menuItem(
                text = "Additional fit parameters",
                icon = icon("chevron-circle-right"),

                # Content
                selectInput(inputId = "full_method",
                            label = "Optimization method",
                            choices = method_choices),

                numericInput(inputId = "full_max_ite",
                             label = "Maximum iterations",
                             min = 1,
                             value = formals(fit.meta.GMCM)$max.ite)
              ),

              # * Input: Fit model ----
              actionButton(inputId = "full_fit_push",
                           label = "Fit model",
                           icon = icon("cogs")),
              br()
            ),

            menuItem(
              text = "Classification",
              icon = icon("box-open"),

              # Content
              radioButtons(inputId = "full_class_type",
                           label = "Classification by",
                           choices = c("Maximum posterior probability" = "max_prob",
                                       "Thresholded maximum posterior probability" = "thres_prob"),
                           selected = "max_prob",
                           inline = FALSE),
              conditionalPanel(
                condition = "input.full_class_type == 'thres_prob'",
                sliderInput(inputId = "full_thres_prob",
                            label = "Threshold",
                            min = 0, max = 1, value = 0.5, step = 0.01)
              ),
              br()
            ),

            menuItem(
              text = "Report",
              icon = icon("file-code"),

              # Content
              br(),
              downloadButton(outputId = "full_dl_html",
                             label = "Download report (.html)",
                             class = "myDownloadButton"),
              br(),br(),
              downloadButton(outputId = "full_dl_rmd",
                             label = "Download source (.Rmd)",
                             class = "myDownloadButton"),
              br(),br(),
              downloadButton(outputId = "full_dl_r",
                             label = "Download code (.R)",
                             class = "myDownloadButton"),
              br(),br()
            )
          )
        ),
        # * General output ----
        dashboardBody(
          h2("General GMCM for unsupervised clustering"),
          br(),

          uiOutput("full_pie_box"),
          uiOutput("full_mu_box"),
          uiOutput("full_sigma_box"),

          uiOutput("full_obs_plot"),
          uiOutput("full_rank_plot"),
          uiOutput("full_latent_plot"),

          uiOutput("full_ui_selectize_model_cols_xy"),
          uiOutput("full_res_theta_plot"),

          uiOutput("full_plot_pie"),
          uiOutput("full_res_mu"),
          uiOutput("full_res_sigma"),

          uiOutput("full_classified_data"),
          uiOutput("full_fit_log")
        )
      )
    ),




    # Special model _______________________________________________________ ----
    tabPanel(
      title = "Special GMCM",
      dashboardPage(
        dashboardHeader(disable = TRUE),
        dashboardSidebar(
          sidebarMenu(

            menuItem(
              text = "Fit model",
              icon = icon("tachometer"),
              startExpanded = FALSE,

              # * Input: Start parameters ----
              menuItem(
                text = "Start parameters",
                icon = icon("chevron-circle-right"),

                # Content
                sliderInput(inputId = "par1",
                            label = "Mixture proportion of spurious signals",
                            min = 0, max = 1, value = 0.7, step = 0.01),

                numericInput(inputId = "par2",
                             label = "Mean value in reproducible component",
                             min = 0, value = 1),

                numericInput(inputId = "par3",
                             label = "Standard deviation in reproducible component",
                             min = 0, value = 1),

                sliderInput(inputId = "par4",
                            label = "Correlation in reproducible component",
                            min = 0, max = 1, value = 0.5, step = 0.01)

              ),

              # * Input: Addtional parameters ----

              menuItem(
                text = "Additional fit parameters",
                icon = icon("chevron-circle-right"),

                # Content
                selectInput(inputId = "meta_method",
                            label = "Optimization method",
                            choices = method_choices),
                            #choices = eval(formals(fit.meta.GMCM)$method)),

                numericInput(inputId = "meta_max_ite",
                             label = "Maximum iterations",
                             min = 1,
                             value = formals(fit.meta.GMCM)$max.ite),

                checkboxInput(inputId = "meta_positive_rho",
                              label = "Force positive correlation",
                              value = formals(fit.meta.GMCM)$positive.rho)
              ),

              # * Input: Large vals => reproducible
              checkboxInput(inputId = "meta_large_vals",
                            label = tagList(HTML(
                              "<strong>Important:</strong>",
                              "Large values indicate strong evidence"),
                              tipify(
                                icon("question-circle"),
                                trigger = "hover",
                                placement = "bottom",
                                title = HTML(
                                  "Should be checked if larger values correspond",
                                  "to stronger evidence and thus hopefully reproducibility.",
                                  "Should <i>not</i> be checked otherwise.",
                                  "If the statistics to be clustered are P-values, for example,",
                                  "the box should <i>not</i> be checked. If they",
                                  "are absolute values of t- or z-statistics or",
                                  "equivalent the box should be checked."
                                )
                              )
                            ),
                            value = TRUE),

              # * Input: Fit model ----
              actionButton(inputId = "meta_fit_push",
                           label = "Fit model",
                           icon = icon("cogs")),
              br()



            ),

            menuItem(
              text = "IDR classification",
              icon = icon("box-open"),

              # Content
              radioButtons(inputId = "meta_IDR_thres_type",
                           label = "Thresholding by",
                           choices = c("Adjusted IDR" = "IDR",
                                       "Local idr" = "idr"),
                           selected = "IDR",
                           inline = TRUE),
              sliderInput(inputId = "meta_IDR_thres",
                          label = "meta_IDR_thres",
                          min = 0, max = 1, value = 0.05, step = 0.01)
            ),

            menuItem(
              text = "Report",
              icon = icon("file-code"),

              # Content
              br(),
              downloadButton(outputId = "meta_dl_html",
                             label = "Download report (.html)",
                             class = "myDownloadButton"),
              br(),br(),
              downloadButton(outputId = "meta_dl_rmd",
                             label = "Download source (.Rmd)",
                             class = "myDownloadButton"),
              br(),br(),
              downloadButton(outputId = "meta_dl_r",
                             label = "Download code (.r)",
                             class = "myDownloadButton"),
              br(),br()
            )

          )

        ),

        # * Meta output ----
        dashboardBody(
          h2("Special GMCM for reproducibility analysis"),
          br(),
          conditionalPanel("input.meta_fit_push > 0",
            uiOutput("infoBoxes"),
            uiOutput("classificationBoxes"),
            box(
              # Box args
              title = "Observed values plot",
              footer = "The raw, observed values classified by the special GMCM approach.",
              status = "primary",
              width = 4,
              collapsible = TRUE,
              collapsed = FALSE,
              solidHeader = TRUE,

              # Content
              plotOutput("obs_plot")
            ),
            box(
              # Box args
              title = "Rank GMCM plot",
              footer = "Values in the top right corresponds to reproducible values. This plots shows the realisation for the Gaussian Mixture Copula Model.",
              status = "primary",
              width = 4,
              collapsible = TRUE,
              collapsed = FALSE,
              solidHeader = TRUE,

              # Content
              plotOutput("rank_plot")
            ),
            box(
              # Box args
              title = "Latent GMM process plot",
              footer = "The ranked observations mapped back to the latent process given the estimated parameters. I.e. this plots shows the estimated latent Gaussian Mixture Model realisations.",
              status = "primary",
              width = 4,
              collapsible = TRUE,
              collapsed = FALSE,
              solidHeader = TRUE,

              # Content
              plotOutput("latent_plot")
            ),
            uiOutput("meta_ui_selectize_model_cols_xy"),
            box(
              title = "Classified data",
              footer = fluidRow(
                column(1, downloadButton('downloadData', 'Download')),
                column(4, checkboxInput(inputId = "meta_dl_include_all_cols",
                                        label = "Include all uploaded columns"))
              ),
              status = "info",
              width = 12,
              collapsible = TRUE,
              collapsed = TRUE,
              solidHeader = TRUE,

              DTOutput("meta_out_file_table")
            )
          )
        )
      )
    ),

    # navbar: More ----
    navbarMenu(
      title = "",
      icon = icon("bars"),


      tabPanel(
        title = "About",
        icon = icon("question"),
        uiOutput('more_about_md')
      ),
      tabPanel(
        title = "Bug reports",
        icon = icon("bug"),
        uiOutput('more_bug_reports_md')
      )
    )

  )
)

