using System.Collections.Generic;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using System.Reflection;

namespace ScriptDomMeetupExtension
{
    public static class TSqlScriptExtension
    {
        public static List<NamedTableReference> GetListUsedTableReference(this TSqlScript script)
        {
            List<NamedTableReference> listObjects = new List<NamedTableReference>();
            RecurseObjectReference(script, "Microsoft.SqlServer.TransactSql.ScriptDom", ref listObjects);
            return listObjects;
        }

        private static void RecurseObjectReference(dynamic obj, string propertyTypeNamespace,
            ref List<NamedTableReference> listObjects, string propertyHierarchy = "")
        {
            if (propertyHierarchy == "")
                propertyHierarchy = obj.GetType().Name;
            foreach (var property in obj.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance))
            {
                if (property.GetIndexParameters().Length == 1)
                {
                    for (short i = 0; i < obj.Count; i++)
                    {
                        ProcessObjectReferenceProperty(property, obj, propertyTypeNamespace, ref listObjects,
                            propertyHierarchy, i);
                    }
                }
                if (property.GetIndexParameters().Length == 0)
                    ProcessObjectReferenceProperty(property, obj, propertyTypeNamespace, ref listObjects,
                        propertyHierarchy);
            }
        }

        private static void ProcessObjectReferenceProperty(dynamic property, dynamic obj, string propertyTypeNamespace,
            ref List<NamedTableReference> listObjects, string propertyHierarchy = "", short index = -1)
        {
            var propertyValue = index == -1 ? property.GetValue(obj) : property.GetValue(obj, new object[] {index});
            if (propertyValue == null)
                return;

            bool isCollection = false;
            if (property.PropertyType.GetInterface("System.Collections.IEnumerable") != null)
                isCollection = true;
            string currentPropertyName = property.Name;
            string currentPropertyType = property.PropertyType.Name;
            string currentPropertyTypeNamespace = property.PropertyType.Namespace;
            if (currentPropertyTypeNamespace == propertyTypeNamespace || currentPropertyType == "String" || isCollection)
            {
                if (isCollection && !(propertyValue is string) && propertyValue != null)
                    foreach (var item in propertyValue)
                        RecurseObjectReference(item, propertyTypeNamespace, ref listObjects,
                            propertyHierarchy + "." + currentPropertyName);
                else
                {
                    if (obj is NamedTableReference)
                    {
                        NamedTableReference table = (NamedTableReference) obj;
                        listObjects.Add(table);
                    }
                    else if (currentPropertyTypeNamespace == propertyTypeNamespace)
                        RecurseObjectReference(propertyValue, propertyTypeNamespace, ref listObjects,
                            propertyHierarchy + "." + currentPropertyName);
                }
            }
        }
    }
}
