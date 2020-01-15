{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "sparkPoolName": {
            "type": "string"
        },
        "workspaceName": {
            "type": "string"
        },
        "location": {
            "type": "string"
        },
        "sparkPoolTags": {
            "type": "object",
            "defaultValue": {}
        },
        "sparkAutoScaleEnabled": {
            "type": "bool"
        },
        "sparkMinNodeCount": {
            "type": "int",
            "defaultValue": 0
        },
        "sparkMaxNodeCount": {
            "type": "int",
            "defaultValue": 0
        },
        "sparkNodeCount": {
            "type": "int",
            "defaultValue": 0
        },
        "sparkNodeSizeFamily": {
            "type": "string"
        },
        "sparkNodeSize": {
            "type": "string"
        },
        "sparkAutoPauseEnabled": {
            "type": "bool"
        },
        "sparkAutoPauseDelayInMinutes": {
            "type": "int",
            "defaultValue": 0
        },
        "sparkVersion": {
            "type": "string"
        },
        "packagesRequirementsFileName": {
            "type": "string",
            "defaultValue": ""
        },
        "packagesRequirementsContent": {
            "type": "string",
            "defaultValue": ""
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Synapse/workspaces/bigDataPools",
            "apiVersion": "2019-06-01-preview",
            "name": "[concat(parameters('workspaceName'), '/', parameters('sparkPoolName'))]",
            "location": "[parameters('location')]",
            "tags": "[parameters('sparkPoolTags')]",
            "properties": {
                "nodeCount": "[parameters('sparkNodeCount')]",
                "nodeSizeFamily": "[parameters('sparkNodeSizeFamily')]",
                "nodeSize": "[parameters('sparkNodeSize')]",
                "autoScale": {
                    "enabled": "[parameters('sparkAutoScaleEnabled')]",
                    "minNodeCount": "[parameters('sparkMinNodeCount')]",
                    "maxNodeCount": "[parameters('sparkMaxNodeCount')]"
                },
                "autoPause": {
                    "enabled": "[parameters('sparkAutoPauseEnabled')]",
                    "delayInMinutes": "[parameters('sparkAutoPauseDelayInMinutes')]"
                },
                "sparkVersion": "[parameters('sparkVersion')]",
                "libraryRequirements": {
                    "filename": "[parameters('packagesRequirementsFileName')]",
                    "content": "[parameters('packagesRequirementsContent')]"
                }
            }
        }
    ],
    "outputs": {}
}