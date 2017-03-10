<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0"
                       xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd"
                       xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
                       xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <NamedLayer>
    <Name>is_user_line</Name>
    <UserStyle>
      <Title>user_line</Title>
      <FeatureTypeStyle>
        <Rule>
          <Title>solid line</Title>
          <ogc:Filter>
            <ogc:And>
              <ogc:Not>
                <ogc:PropertyIsNull>
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                </ogc:PropertyIsNull>  
              </ogc:Not>
              <ogc:PropertyIsEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>0</ogc:Literal>
                  <ogc:Literal>4</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>line</ogc:Literal>
              </ogc:PropertyIsEqualTo>
              <ogc:PropertyIsNotEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>5</ogc:Literal>
                  <ogc:Literal>11</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>ncolor</ogc:Literal>
              </ogc:PropertyIsNotEqualTo>
               <ogc:PropertyIsEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>19</ogc:Literal>
                  <ogc:Literal>22</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>000</ogc:Literal>
              </ogc:PropertyIsEqualTo>
            </ogc:And>            
          </ogc:Filter>

          <LineSymbolizer>
            <Stroke>
              <CssParameter name="stroke">
                <ogc:Function name="Concatenate">
                  <ogc:Literal>#</ogc:Literal>
                  <ogc:Function name="strSubstring">
                    <ogc:PropertyName>class_id</ogc:PropertyName>
                    <ogc:Literal>5</ogc:Literal>
                    <ogc:Literal>11</ogc:Literal>
                  </ogc:Function>
                </ogc:Function>
              </CssParameter>
              <CssParameter name="stroke-width">
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>12</ogc:Literal>
                  <ogc:Literal>14</ogc:Literal>
                </ogc:Function>
              </CssParameter>
            </Stroke>
          </LineSymbolizer>
        </Rule>
        
        <Rule>
          <Title>dashed line</Title>
          <ogc:Filter>
            <ogc:And>
              <ogc:Not>
                <ogc:PropertyIsNull>
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                </ogc:PropertyIsNull>  
              </ogc:Not>
              <ogc:PropertyIsEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>0</ogc:Literal>
                  <ogc:Literal>4</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>line</ogc:Literal>
              </ogc:PropertyIsEqualTo>
			<ogc:PropertyIsNotEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>5</ogc:Literal>
                  <ogc:Literal>11</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>ncolor</ogc:Literal>
              </ogc:PropertyIsNotEqualTo>
			<ogc:PropertyIsNotEqualTo>
				<ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>19</ogc:Literal>
                  <ogc:Literal>22</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>000</ogc:Literal>
              </ogc:PropertyIsNotEqualTo>
			<ogc:Not> 
				<ogc:PropertyIsNull>
					<ogc:Function name="strSubstring">
					  <ogc:PropertyName>class_id</ogc:PropertyName>
					  <ogc:Literal>23</ogc:Literal>
					  <ogc:Literal>25</ogc:Literal>
					</ogc:Function>
				  </ogc:PropertyIsNull>
			</ogc:Not>
            </ogc:And>
		</ogc:Filter>

          <LineSymbolizer>
            <Stroke>
              <CssParameter name="stroke">
                <ogc:Function name="Concatenate">
                  <ogc:Literal>#</ogc:Literal>
                  <ogc:Function name="strSubstring">
                    <ogc:PropertyName>class_id</ogc:PropertyName>
                    <ogc:Literal>5</ogc:Literal>
                    <ogc:Literal>11</ogc:Literal>
                  </ogc:Function>
                </ogc:Function>
              </CssParameter>
              <CssParameter name="stroke-width">
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>12</ogc:Literal>
                  <ogc:Literal>14</ogc:Literal>
                </ogc:Function>
              </CssParameter>
              <CssParameter name="stroke-opacity">
                <ogc:Function name="parseDouble">
                  <ogc:Function name="strSubstring">
                    <ogc:PropertyName>class_id</ogc:PropertyName>
                    <ogc:Literal>15</ogc:Literal>
                    <ogc:Literal>18</ogc:Literal>
                  </ogc:Function>
                </ogc:Function> 
              </CssParameter>
              <CssParameter name="stroke-dasharray">
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>19</ogc:Literal>
                  <ogc:Literal>21</ogc:Literal>
                </ogc:Function>
              </CssParameter>
              <CssParameter name="stroke-dashoffset">
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>23</ogc:Literal>
                  <ogc:Literal>25</ogc:Literal>
                </ogc:Function>
              </CssParameter>
            </Stroke>
          </LineSymbolizer>
        </Rule>
        
        <Rule>
        <Title>solid line (linejoin-mitre)</Title>
          <ogc:Filter>
            <ogc:And>
              <ogc:Not>
                <ogc:PropertyIsNull>
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                </ogc:PropertyIsNull>  
              </ogc:Not>
              <ogc:PropertyIsEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>0</ogc:Literal>
                  <ogc:Literal>4</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>line</ogc:Literal>
              </ogc:PropertyIsEqualTo>
              <ogc:PropertyIsNotEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>5</ogc:Literal>
                  <ogc:Literal>11</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>ncolor</ogc:Literal>
              </ogc:PropertyIsNotEqualTo>
               <ogc:PropertyIsEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>19</ogc:Literal>
                  <ogc:Literal>22</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>000</ogc:Literal>
              </ogc:PropertyIsEqualTo>
               <ogc:PropertyIsEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>23</ogc:Literal>
                  <ogc:Literal>25</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>01</ogc:Literal>
              </ogc:PropertyIsEqualTo>
            </ogc:And>            
          </ogc:Filter>

          <LineSymbolizer>
            <Stroke>
              <CssParameter name="stroke">
                <ogc:Function name="Concatenate">
                  <ogc:Literal>#</ogc:Literal>
                  <ogc:Function name="strSubstring">
                    <ogc:PropertyName>class_id</ogc:PropertyName>
                    <ogc:Literal>5</ogc:Literal>
                    <ogc:Literal>11</ogc:Literal>
                  </ogc:Function>
                </ogc:Function>
              </CssParameter>
              <CssParameter name="stroke-width">
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>12</ogc:Literal>
                  <ogc:Literal>14</ogc:Literal>
                </ogc:Function>
              </CssParameter>
              <CssParameter name="stroke-linejoin">mitre</CssParameter>    
			
            </Stroke>
          </LineSymbolizer>
        </Rule>
        
		<Rule>
        <Title>solid line (linejoin-round)</Title>
          <ogc:Filter>
            <ogc:And>
              <ogc:Not>
                <ogc:PropertyIsNull>
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                </ogc:PropertyIsNull>  
              </ogc:Not>
              <ogc:PropertyIsEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>0</ogc:Literal>
                  <ogc:Literal>4</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>line</ogc:Literal>
              </ogc:PropertyIsEqualTo>
              <ogc:PropertyIsNotEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>5</ogc:Literal>
                  <ogc:Literal>11</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>ncolor</ogc:Literal>
              </ogc:PropertyIsNotEqualTo>
               <ogc:PropertyIsEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>19</ogc:Literal>
                  <ogc:Literal>22</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>000</ogc:Literal>
              </ogc:PropertyIsEqualTo>
               <ogc:PropertyIsEqualTo>
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>23</ogc:Literal>
                  <ogc:Literal>25</ogc:Literal>
                </ogc:Function>
                <ogc:Literal>02</ogc:Literal>
              </ogc:PropertyIsEqualTo>
            </ogc:And>            
          </ogc:Filter>

          <LineSymbolizer>
            <Stroke>
              <CssParameter name="stroke">
                <ogc:Function name="Concatenate">
                  <ogc:Literal>#</ogc:Literal>
                  <ogc:Function name="strSubstring">
                    <ogc:PropertyName>class_id</ogc:PropertyName>
                    <ogc:Literal>5</ogc:Literal>
                    <ogc:Literal>11</ogc:Literal>
                  </ogc:Function>
                </ogc:Function>
              </CssParameter>
              <CssParameter name="stroke-width">
                <ogc:Function name="strSubstring">
                  <ogc:PropertyName>class_id</ogc:PropertyName>
                  <ogc:Literal>12</ogc:Literal>
                  <ogc:Literal>14</ogc:Literal>
                </ogc:Function>
              </CssParameter>
              <CssParameter name="stroke-linejoin">round</CssParameter>    
			
            </Stroke>
          </LineSymbolizer>
        </Rule>

      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
