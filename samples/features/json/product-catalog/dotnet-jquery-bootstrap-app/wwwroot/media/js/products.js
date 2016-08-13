ROOT_API_URL = "/api/Product/";

var ProductController = function($table, $form, $modal){

    return {
        editProduct: function () {
            $form.loadJSON(ROOT_API_URL + this.attributes["data-id"].value);
        },
        saveProduct: function () {
            var id = $("#ProductID", $form).val();
            $.ajax({
                contentType: 'application/json',
                method: id == "" ? "POST" : "PUT",
                url: ROOT_API_URL + id,
                processData: false,
                data: JSON.stringify($form.serializeJSON({ checkboxUncheckedValue: "false", parseAll: true })),
            }).fail(function (msg) {
                toastr.error('An error occured while trying to save the product.');
            }).done(function () {
                toastr.success("Product is successfully saved!");
                $table.ajax.reload(null, false);
                $modal.modal('hide');
            });
        },

        deleteProduct: function () {
            $.ajax({
                method: "DELETE",
                url: ROOT_API_URL + this.attributes["data-id"].value
            }).fail(function (msg) {
                toastr.error('An error occured while trying to delete the product.', 'Product cannot be deleted!');
            }).done(function () {
                toastr.success("Product is successfully deleted!");
                $table.ajax.reload(null, false);
            });
        }
    }
};


$(document).ready(function () {

    // DataTable setup
    var $table = $('#example').DataTable({
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
    
    // modal setup
    $modal = $('#myModal');
    
    $modal.on('hide.bs.modal', function () {
        $(this).find("input[type!=checkbox],textarea,select").val('').end();
        $(this).find("input:checkbox").prop('checked', false);
    });

    $("#cancelButton", $modal).on("click", function () {
        $modal.modal('hide');
    });
    // end modal setup

    var ctrl = ProductController($table, $("#ProductForm"), $modal);

    $table.on("click", "button.edit", ctrl.editProduct);

    $table.on("click", "button.delete", ctrl.deleteProduct);

    $("#submitButton", $modal).on("click", function (e) {
        e.preventDefault();
        ctrl.saveProduct();
    });
});