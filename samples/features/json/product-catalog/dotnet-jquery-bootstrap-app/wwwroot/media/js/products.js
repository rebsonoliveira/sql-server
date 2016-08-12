ROOT_API_URL = "/api/Product/";

$(document).ready(function () {

    var table = $('#example').DataTable({
        "ajax": ROOT_API_URL,
        "columns": [
            { "data": "Name" },
            { "data": "Color", "defaultContent": "" },
            { "data": "Price", sType: 'numeric', "defaultContent": "" },
            { "data": "Quantity", "visible": true, "defaultContent": "" },
            { "data": "MadeIn", "visible": true, "defaultContent": "" },
            { "data": "Tags", "visible": true, "defaultContent": "" },
            {
                "data": "ProductID",
                "sortable": false,
                "render": function (data) {
                    return '<button data-id="' + data + '" class="btn btn-primary btn-sm edit" data-toggle="modal" data-target="#myModal"><span class="glyphicon glyphicon-edit"></span> Edit</button>';
                }
            },
            {
                "data": "ProductID",
                "sortable": false,
                "render": function (data) {
                    return '<button data-id="' + data + '" class="btn btn-danger btn-sm delete"><span class="glyphicon glyphicon-remove"></span> Delete</button>';
                }
            }
        ]
    });// end DataTable setup
    
    $('#myModal').on('hide.bs.modal', function () {
        $(this).find("input[type!=checkbox],textarea,select").val('').end();
        $(this).find("input:checkbox").prop('checked', false);
    });

    $("table#example").on("click", "button.edit", function () {
        $("#ProductForm")
            .loadJSON(ROOT_API_URL + this.attributes["data-id"].value);
    });

    $("table#example").on("click", "button.delete", function () {

        $.ajax({
            method: "DELETE",
            url: ROOT_API_URL + this.attributes["data-id"].value
        }).fail(function (msg) {
            toastr.error('An error occured while trying to delete the product.', 'Product cannot be deleted!');
        }).done(function () {
            toastr.success("Product is successfully deleted!");
            $('#example').DataTable().ajax.reload(null, false);
        });
    });

    $("#submitButton").on("click", function (e) {
        e.preventDefault();
        var id = $("#ProductID").val();
        $.ajax({
            contentType: 'application/json',
            method: id == "" ? "POST" : "PUT",
            url: ROOT_API_URL + id,
            processData: false,
            data: JSON.stringify($('#ProductForm').serializeJSON({ checkboxUncheckedValue: "false", parseAll: true })),
           
        }).fail(function (msg) {
            toastr.error('An error occured while trying to save the product.');
        }).done(function () {
            toastr.success("Product is successfully saved!");
            $('#example').DataTable().ajax.reload(null, false);
            $('#myModal').modal('hide');
        });
    });

    $("#cancelButton").on("click", function () {
        $('#myModal').modal('hide');
    });
});