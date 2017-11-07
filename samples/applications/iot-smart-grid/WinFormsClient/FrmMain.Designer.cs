namespace Client
{
    partial class FrmMain
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.Windows.Forms.DataVisualization.Charting.ChartArea chartArea3 = new System.Windows.Forms.DataVisualization.Charting.ChartArea();
            System.Windows.Forms.DataVisualization.Charting.Legend legend3 = new System.Windows.Forms.DataVisualization.Charting.Legend();
            System.Windows.Forms.DataVisualization.Charting.Series series3 = new System.Windows.Forms.DataVisualization.Charting.Series();
            System.Windows.Forms.DataVisualization.Charting.DataPoint dataPoint3 = new System.Windows.Forms.DataVisualization.Charting.DataPoint(0D, 0D);
            this.bottomToolStrip = new System.Windows.Forms.ToolStrip();
            this.lblTasksTitle = new System.Windows.Forms.ToolStripLabel();
            this.lblTasksValue = new System.Windows.Forms.ToolStripLabel();
            this.Start = new System.Windows.Forms.Button();
            this.Stop = new System.Windows.Forms.Button();
            this.rpsTimer = new System.Windows.Forms.Timer(this.components);
            this.Reset = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.lblRpsValue = new System.Windows.Forms.Label();
            this.stopTimer = new System.Windows.Forms.Timer(this.components);
            this.RpsChart = new System.Windows.Forms.DataVisualization.Charting.Chart();
            this.bottomToolStrip.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.RpsChart)).BeginInit();
            this.SuspendLayout();
            // 
            // bottomToolStrip
            // 
            this.bottomToolStrip.BackColor = System.Drawing.Color.White;
            this.bottomToolStrip.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.bottomToolStrip.ImageScalingSize = new System.Drawing.Size(24, 24);
            this.bottomToolStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.lblTasksTitle,
            this.lblTasksValue});
            this.bottomToolStrip.Location = new System.Drawing.Point(0, 505);
            this.bottomToolStrip.Name = "bottomToolStrip";
            this.bottomToolStrip.Size = new System.Drawing.Size(1336, 25);
            this.bottomToolStrip.TabIndex = 0;
            this.bottomToolStrip.Text = "toolStrip1";
            // 
            // lblTasksTitle
            // 
            this.lblTasksTitle.Font = new System.Drawing.Font("Segoe UI", 12F);
            this.lblTasksTitle.ForeColor = System.Drawing.Color.DimGray;
            this.lblTasksTitle.Name = "lblTasksTitle";
            this.lblTasksTitle.Size = new System.Drawing.Size(129, 22);
            this.lblTasksTitle.Text = "Number of Tasks:";
            this.lblTasksTitle.Visible = false;
            // 
            // lblTasksValue
            // 
            this.lblTasksValue.Font = new System.Drawing.Font("Segoe UI", 12F);
            this.lblTasksValue.Name = "lblTasksValue";
            this.lblTasksValue.Size = new System.Drawing.Size(19, 22);
            this.lblTasksValue.Text = "0";
            this.lblTasksValue.Visible = false;
            // 
            // Start
            // 
            this.Start.FlatAppearance.BorderColor = System.Drawing.Color.Silver;
            this.Start.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.Start.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Start.Location = new System.Drawing.Point(930, 569);
            this.Start.Name = "Start";
            this.Start.Size = new System.Drawing.Size(112, 50);
            this.Start.TabIndex = 2;
            this.Start.Text = "Start";
            this.Start.UseVisualStyleBackColor = true;
            this.Start.Click += new System.EventHandler(this.Start_Click);
            // 
            // Stop
            // 
            this.Stop.Enabled = false;
            this.Stop.FlatAppearance.BorderColor = System.Drawing.Color.Silver;
            this.Stop.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.Stop.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Stop.Location = new System.Drawing.Point(1191, 479);
            this.Stop.Name = "Stop";
            this.Stop.Size = new System.Drawing.Size(111, 41);
            this.Stop.TabIndex = 3;
            this.Stop.Text = "Close";
            this.Stop.UseVisualStyleBackColor = true;
            this.Stop.Click += new System.EventHandler(this.Stop_Click);
            // 
            // rpsTimer
            // 
            this.rpsTimer.Interval = 500;
            this.rpsTimer.Tick += new System.EventHandler(this.rpsTimer_Tick);
            // 
            // Reset
            // 
            this.Reset.BackColor = System.Drawing.Color.White;
            this.Reset.FlatAppearance.BorderColor = System.Drawing.Color.Silver;
            this.Reset.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.Reset.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Reset.Location = new System.Drawing.Point(764, 569);
            this.Reset.Name = "Reset";
            this.Reset.Size = new System.Drawing.Size(160, 50);
            this.Reset.TabIndex = 103;
            this.Reset.Text = "Setup/Reset DB";
            this.Reset.UseVisualStyleBackColor = false;
            this.Reset.Click += new System.EventHandler(this.Reset_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 22F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.Color.DimGray;
            this.label1.Location = new System.Drawing.Point(101, 14);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(255, 36);
            this.label1.TabIndex = 104;
            this.label1.Text = "rows inserted/sec:";
            // 
            // lblRpsValue
            // 
            this.lblRpsValue.AutoSize = true;
            this.lblRpsValue.Font = new System.Drawing.Font("Microsoft Sans Serif", 27.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblRpsValue.ForeColor = System.Drawing.Color.Red;
            this.lblRpsValue.Location = new System.Drawing.Point(351, 12);
            this.lblRpsValue.Name = "lblRpsValue";
            this.lblRpsValue.Size = new System.Drawing.Size(39, 42);
            this.lblRpsValue.TabIndex = 105;
            this.lblRpsValue.Text = "0";
            // 
            // stopTimer
            // 
            this.stopTimer.Interval = 6000;
            this.stopTimer.Tick += new System.EventHandler(this.stopTimer_Tick);
            // 
            // RpsChart
            // 
            this.RpsChart.BackColor = System.Drawing.Color.Transparent;
            this.RpsChart.BorderlineColor = System.Drawing.Color.Black;
            chartArea3.AxisX.IntervalType = System.Windows.Forms.DataVisualization.Charting.DateTimeIntervalType.Seconds;
            chartArea3.AxisX.LabelAutoFitMaxFontSize = 8;
            chartArea3.AxisX.LineColor = System.Drawing.Color.DimGray;
            chartArea3.AxisX.MajorGrid.Enabled = false;
            chartArea3.AxisX.MajorGrid.Interval = 0D;
            chartArea3.AxisX.MajorGrid.IntervalOffset = 0D;
            chartArea3.AxisX.MajorGrid.IntervalType = System.Windows.Forms.DataVisualization.Charting.DateTimeIntervalType.Auto;
            chartArea3.AxisX.MajorTickMark.Enabled = false;
            chartArea3.AxisX.Maximum = 100D;
            chartArea3.AxisX.Minimum = 0D;
            chartArea3.AxisX.Title = "Seconds";
            chartArea3.AxisX.TitleFont = new System.Drawing.Font("Tahoma", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            chartArea3.AxisY.LabelAutoFitMaxFontSize = 8;
            chartArea3.AxisY.LineColor = System.Drawing.Color.DimGray;
            chartArea3.AxisY.MajorGrid.Enabled = false;
            chartArea3.AxisY.Minimum = 0D;
            chartArea3.AxisY.Title = "Number Of Rows";
            chartArea3.AxisY.TitleFont = new System.Drawing.Font("Tahoma", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            chartArea3.BackColor = System.Drawing.Color.Transparent;
            chartArea3.Name = "Chart";
            this.RpsChart.ChartAreas.Add(chartArea3);
            legend3.BackColor = System.Drawing.Color.Transparent;
            legend3.Enabled = false;
            legend3.ForeColor = System.Drawing.Color.Maroon;
            legend3.Name = "Legend1";
            this.RpsChart.Legends.Add(legend3);
            this.RpsChart.Location = new System.Drawing.Point(12, 56);
            this.RpsChart.Name = "RpsChart";
            this.RpsChart.Palette = System.Windows.Forms.DataVisualization.Charting.ChartColorPalette.None;
            series3.ChartArea = "Chart";
            series3.ChartType = System.Windows.Forms.DataVisualization.Charting.SeriesChartType.Area;
            series3.Color = System.Drawing.Color.DimGray;
            series3.Font = new System.Drawing.Font("Microsoft Sans Serif", 6F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            series3.Legend = "Legend1";
            series3.LegendText = "sadsaDS";
            series3.MarkerBorderWidth = 3;
            series3.Name = "RPS";
            series3.Points.Add(dataPoint3);
            this.RpsChart.Series.Add(series3);
            this.RpsChart.Size = new System.Drawing.Size(1324, 419);
            this.RpsChart.TabIndex = 106;
            this.RpsChart.Text = "Rows / Sec";
            // 
            // FrmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1336, 530);
            this.Controls.Add(this.RpsChart);
            this.Controls.Add(this.lblRpsValue);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.Reset);
            this.Controls.Add(this.Stop);
            this.Controls.Add(this.Start);
            this.Controls.Add(this.bottomToolStrip);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Name = "FrmMain";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "IoT Smart City - Event Monitoring";
            this.bottomToolStrip.ResumeLayout(false);
            this.bottomToolStrip.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.RpsChart)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ToolStrip bottomToolStrip;
        private System.Windows.Forms.ToolStripLabel lblTasksTitle;
        private System.Windows.Forms.ToolStripLabel lblTasksValue;
        private System.Windows.Forms.Button Start;
        private System.Windows.Forms.Button Stop;
        private System.Windows.Forms.Timer rpsTimer;
        private System.Windows.Forms.Button Reset;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label lblRpsValue;
        private System.Windows.Forms.Timer stopTimer;
        private System.Windows.Forms.DataVisualization.Charting.Chart RpsChart;
    }
}

