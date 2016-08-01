jqdtAjaxSource = "/api/Product";

var $dialog;

function fnAddProduct() {
    var id = $("#ProductID", $dialog).val();
    $.ajax({

        contentType: 'application/json',
        method: id == "" ? "POST" : "PUT",
        url: '/api/Product/' + id,
        processData: false,
        data: JSON.stringify($('#ProductForm').serializeJSON({ checkboxUncheckedValue: "false", parseAll: true })),

    }).fail(function (msg) {
        alert(msg);
    }).done(function () {
        $('#example').DataTable().ajax.reload(null, false);
        $dialog.dialog('close');
    });
}


$(document).ready(function () {

    $dialog = $("#product-form").dialog({
        autoOpen: false,
        width: '300px',
        modal: true,
        buttons: {
            Save: fnAddProduct,
            Cancel: function () {
                //fnReset();

                $dialog.dialog("close");
            }
        },
        //close: fnReset
    });

    var form = $dialog.find("form").on("submit", function (event) {
        event.preventDefault();
        fnAddNote();
    });

    var table = $('#example').DataTable({
        "sAjaxSource": jqdtAjaxSource,
        "columns": [
            { "data": "Name" },
            { "data": "Color", "defaultContent": "" },
            { "data": "Size", "defaultContent": "" },
            { "data": "Price", sType: 'numeric', "defaultContent": "" },
            { "data": "Quantity", "visible": true, "defaultContent": "" },
            {
                "data": "ProductID",
                "sortable": false,
                "render": function (data) {
                    return '<button data-id="' + data + '" class="btn btn-primary edit" data-toggle="modal" data-target="#myModal"><span class="glyphicon glyphicon-edit"></span> Edit</button>';
                }
            },
            {
                "data": "ProductID",
                "sortable": false,
                "render": function (data) {
                    return '<button data-id="' + data + '" class="btn btn-danger delete"><span class="glyphicon glyphicon-remove"></span> Delete</button>';
                }
            }
        ]
    });

    $("table#example").on("click", "button.edit", function () {
        $("#ProductForm")
            .loadJSON('/api/Product/' + this.attributes["data-id"].value, 
            { "onLoaded": function () { $dialog.dialog('open'); } });
    });

    $("table#example").on("click", "button.delete", function () {

        $.ajax({
            method: "DELETE",
            url: '/api/Product/' + this.attributes["data-id"].value
        }).fail(function (msg) {
            alert(msg);
        }).done(function () {
            alert("Deleted");
            $('#example').DataTable().ajax.reload(null, false);
        });
    });


});