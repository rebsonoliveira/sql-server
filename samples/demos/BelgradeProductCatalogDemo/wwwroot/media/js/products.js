ROOT_API_URL = "/api/Product/";

// ProductController is an object that contains actions the will be executed on
// get, save (create or update), delete
var ProductController =
    function ($table, $modal, $modalAddProduct) {

        return {

            getProduct: function (productID) {
                $.ajax({ url: ROOT_API_URL + productID, cache: false })
                    .done( function (json) {
                        $modal.loadJSON(json);
                    })
                    .fail(function () {
                        toastr.error('An error occured while trying to get the product.');
                    });
            },

            saveProduct: function (productID, product) {
                $.ajax({
                    contentType: 'application/json',
                    method: (productID === null) ? "POST" : "PUT",
                    url: ROOT_API_URL + (productID||""),
                    processData: false,
                    data: product,
                }).fail(function (msg) {
                    toastr.error('An error occured while trying to save the product.');
                }).done(function () {
                    toastr.success("Product is successfully saved!");
                    $table.ajax.reload(null, false);
                    if (productID === null)
                        $modalAddProduct.modal('hide');
                    else
                        $modal.modal('hide');
                });
            },

            deleteProduct: function (productID) {
                $.ajax({
                    method: "DELETE",
                    url: ROOT_API_URL + productID
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
        "ajax": ROOT_API_URL + 'temporal',
        "columns": [
            { "className": 'details-control', "visible": true, "sortable": false, "searchable": false, "defaultContent": "" },
            { "data": "Name" },
            { "data": "Color", "defaultContent": "" },
            { "data": "Price", sType: 'numeric', "defaultContent": "" },
            { "data": "Quantity", "visible": true, "defaultContent": "" },
            { "data": "MadeIn", "visible": true, "defaultContent": "" },
            { "data": "Tags", "visible": true, "defaultContent": "" },
            {
                "data": "ProductID",
                "sortable": false,
                "searchable": false,
                "render": function (data) {
                    return '<button data-id="' + data + '" class="btn btn-primary btn-sm edit" data-toggle="modal" data-target="#modalEditProduct"><span class="glyphicon glyphicon-edit"></span> Edit</button>';
                }
            },
            {
                "data": "ProductID",
                "sortable": false,
                "searchable": false,
                "render": function (data) {
                    return '<button data-id="' + data + '" class="btn btn-danger btn-sm delete"><span class="glyphicon glyphicon-remove"></span> Delete</button>';
                }
            },
            {
                "data": "ProductID",
                "visible": false,
                "sortable": false,
                "searchable": false,
                "render": function (data, type, full) {
                    return '<a href="' + ROOT_API_URL + 'restore?ProductID=' + data + '&DateModified=' + full.DateModified + '" class="restore btn btn-success btn-sm delete"><span class="glyphicon glyphicon-floppy-open"></span> Restore</button>';
                }
            }
        ]
    });// end DataTable setup
    
    // Bootstrap modal setup
    $modalEditProduct = $('#modalEditProduct');
    $modalEditProduct.on('hide.bs.modal', function () {
        $(this).find("input[type!=checkbox],textarea,select").val('').end();
        $(this).find("input:checkbox").prop('checked', false);
    });

    $("#cancelEditButton", $modalEditProduct).on("click", function () {
        $modalEditProduct.modal('hide');
    });

    $modalAddProduct = $('#modalAddProduct');
    $modalAddProduct.on('hide.bs.modal', function () {
        $(this).find("input[type!=checkbox],textarea,select").val('').end();
        $(this).find("input:checkbox").prop('checked', false);
    });

    $("#cancelAddButton", $modalAddProduct).on("click", function () {
        $modalAddProduct.modal('hide');
    });
    // end modal setup

    var ctrl = ProductController($table, $modalEditProduct, $modalAddProduct);

    $table.on("click", "button.edit",
        function () {
            ctrl.getProduct(this.attributes["data-id"].value);
        });

    $table.on("click", "button.delete",
        function () {
            ctrl.deleteProduct(this.attributes["data-id"].value);
        });

    $('body').on("click", "#submitEditButton",
        function (e) {
            e.preventDefault();
            var $form = $("#EditProductForm");
            var productId = $("#ProductID", $form).val();
            var product = JSON.stringify($form.serializeJSON({ checkboxUncheckedValue: "false", parseAll: true }));
            ctrl.saveProduct(productId, product);
    });

    $('body').on("click", "#submitAddButton",
    function (e) {
        e.preventDefault();
        var $form = $("#AddProductForm");
        var product = JSON.stringify($form.serializeJSON({ checkboxUncheckedValue: "false", parseAll: true }));
        ctrl.saveProduct(null, product);
    });

    $.ajax("/api/Company").done(function (json) {
        $("#CompanyList").loadJSON(json);
    });

    $("li a.user-role").on("click", function () {
        localStorage.User = $(this).text();
    });

    $("span.UserGreeting").text(localStorage.User);
    
});